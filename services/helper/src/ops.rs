pub mod core {
    use once_cell::sync::Lazy;
    use serde::{Deserialize, Serialize};
    use sha2::{Digest, Sha256};
    use std::fs::{File, Metadata, OpenOptions};
    use std::io::{BufRead, BufReader, Error, Read};
    use std::process::{Command, Stdio};
    use std::sync::atomic::{AtomicBool, Ordering};
    use std::sync::{Arc, Mutex};
    use std::thread;
    use std::time::{Duration, UNIX_EPOCH};

    use super::logs::log_message;

    const HASH_BUFFER_SIZE: usize = 65536;

    #[derive(Debug, Deserialize, Serialize, Clone)]
    pub struct StartParams {
        pub path: String,
        pub arg: String,
        pub home_dir: Option<String>,
    }

    #[derive(Debug, Clone)]
    struct CachedFileHash {
        path: String,
        size: u64,
        modified_nanos: u128,
        hash: String,
    }

    static PROCESS: Lazy<Arc<Mutex<Option<std::process::Child>>>> =
        Lazy::new(|| Arc::new(Mutex::new(None)));
    static FILE_HASH_CACHE: Lazy<Arc<Mutex<Option<CachedFileHash>>>> =
        Lazy::new(|| Arc::new(Mutex::new(None)));

    pub fn start_core(start_params: StartParams) -> String {
        if let Err(e) = validate_core_path(&start_params.path) {
            log_message(e.clone());
            return e;
        }

        let file = match OpenOptions::new().read(true).open(&start_params.path) {
            Ok(f) => f,
            Err(e) => {
                let msg = format!("Failed to open file: {}", e);
                log_message(msg.clone());
                return msg;
            }
        };

        if let Err(e) = file.lock_shared() {
            let msg = format!("Failed to lock file: {}", e);
            log_message(msg.clone());
            return msg;
        }

        let sha256 = match sha256_file_with_lock(&file, &start_params.path) {
            Ok(hash) => hash,
            Err(e) => {
                let _ = file.unlock();
                let msg = format!("Failed to calculate SHA256: {}", e);
                log_message(msg.clone());
                return msg;
            }
        };

        if sha256 != env!("TOKEN") {
            let _ = file.unlock();
            let msg = format!("The SHA256 hash of the program requesting execution is: {}. The helper program only allows execution of applications with the SHA256 hash: {}.", sha256, env!("TOKEN"));
            log_message(msg.clone());
            return msg;
        }

        let _ = file.unlock();
        drop(file);

        stop_core();
        let mut process = PROCESS.lock().unwrap_or_else(|e| e.into_inner());

        let mut command = Command::new(&start_params.path);
        command.stderr(Stdio::piped()).arg(&start_params.arg);

        if let Some(home_dir) = &start_params.home_dir {
            command.env("SAFE_PATHS", home_dir);
        }

        match command.spawn() {
            Ok(child) => {
                *process = Some(child);

                if let Some(ref mut child) = *process {
                    if let Some(stderr) = child.stderr.take() {
                        let reader = std::io::BufReader::new(stderr);
                        thread::spawn(move || {
                            for line in reader.lines() {
                                match line {
                                    Ok(output) => log_message(output),
                                    Err(_) => break,
                                }
                            }
                        });
                    }
                }
                start_dev_core_exit_watcher();
                "".to_string()
            }
            Err(e) => {
                log_message(e.to_string());
                e.to_string()
            }
        }
    }

    static WATCHER_STARTED: AtomicBool = AtomicBool::new(false);

    fn start_dev_core_exit_watcher() {
        if !should_exit_service_when_core_exits() {
            return;
        }
        if WATCHER_STARTED.swap(true, Ordering::SeqCst) {
            return;
        }

        thread::spawn(|| loop {
            thread::sleep(Duration::from_millis(500));

            let mut process = PROCESS.lock().unwrap_or_else(|e| e.into_inner());
            let Some(child) = process.as_mut() else {
                WATCHER_STARTED.store(false, Ordering::SeqCst);
                break;
            };

            match child.try_wait() {
                Ok(Some(status)) => {
                    log_message(format!("Core process exited: {}", status));
                    *process = None;
                    drop(process);
                    log_message("Dev helper service exiting after core exit".to_string());
                    std::process::exit(0);
                }
                Ok(None) => {}
                Err(e) => {
                    log_message(format!("Failed to monitor core process: {}", e));
                    *process = None;
                    drop(process);
                    std::process::exit(1);
                }
            }
        });
    }

    fn should_exit_service_when_core_exits() -> bool {
        env_contains_dev("HELPER_SERVICE_NAME")
            || env_contains_dev("HELPER_PIPE_NAME")
            || current_exe_name_contains_dev()
    }

    fn env_contains_dev(name: &str) -> bool {
        std::env::var(name)
            .map(|value| value.contains("Dev"))
            .unwrap_or(false)
    }

    fn current_exe_name_contains_dev() -> bool {
        std::env::current_exe()
            .ok()
            .and_then(|path| {
                path.file_stem()
                    .map(|stem| stem.to_string_lossy().to_string())
            })
            .map(|name| name.contains("Dev"))
            .unwrap_or(false)
    }

    fn validate_core_path(path: &str) -> Result<(), String> {
        let path = std::path::Path::new(path);
        if !path.is_absolute() {
            return Err("core path must be absolute".to_string());
        }
        if path
            .components()
            .any(|c| matches!(c, std::path::Component::ParentDir))
        {
            return Err("core path must not contain '..'".to_string());
        }
        Ok(())
    }

    pub fn stop_core() -> String {
        let mut process = PROCESS.lock().unwrap_or_else(|e| e.into_inner());
        if let Some(mut child) = process.take() {
            let _ = child.kill();
            let _ = child.wait();
        }
        *process = None;
        "".to_string()
    }

    fn metadata_signature(metadata: &Metadata) -> Result<(u64, u128), Error> {
        let modified_nanos = metadata
            .modified()?
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        Ok((metadata.len(), modified_nanos))
    }

    fn sha256_file_with_lock(file: &File, path: &str) -> Result<String, Error> {
        let metadata = file.metadata()?;
        let (size, modified_nanos) = metadata_signature(&metadata)?;

        if let Ok(cache_guard) = FILE_HASH_CACHE.lock() {
            if let Some(cache) = cache_guard.as_ref() {
                if cache.path == path
                    && cache.size == size
                    && cache.modified_nanos == modified_nanos
                {
                    return Ok(cache.hash.clone());
                }
            }
        }

        let mut hasher = Sha256::new();
        let mut buffer = [0; HASH_BUFFER_SIZE];
        let mut reader = BufReader::new(file);

        loop {
            let bytes_read = reader.read(&mut buffer)?;
            if bytes_read == 0 {
                break;
            }
            hasher.update(&buffer[..bytes_read]);
        }

        let hash = format!("{:x}", hasher.finalize());
        if let Ok(mut cache_guard) = FILE_HASH_CACHE.lock() {
            *cache_guard = Some(CachedFileHash {
                path: path.to_string(),
                size,
                modified_nanos,
                hash: hash.clone(),
            });
        }
        Ok(hash)
    }
}

pub mod logs {
    use once_cell::sync::Lazy;
    use std::collections::VecDeque;
    use std::sync::{Arc, Mutex};

    const MAX_LOG_ENTRIES: usize = 100;

    static LOGS: Lazy<Arc<Mutex<VecDeque<String>>>> =
        Lazy::new(|| Arc::new(Mutex::new(VecDeque::with_capacity(MAX_LOG_ENTRIES))));

    pub fn log_message(message: String) {
        let mut log_buffer = LOGS.lock().unwrap_or_else(|e| e.into_inner());
        if log_buffer.len() == MAX_LOG_ENTRIES {
            log_buffer.pop_front();
        }
        log_buffer.push_back(message);
    }

    pub fn logs() -> Vec<String> {
        LOGS.lock()
            .unwrap_or_else(|e| e.into_inner())
            .iter()
            .cloned()
            .collect()
    }
}

pub mod process {
    use serde::{Deserialize, Serialize};

    #[derive(Debug, Deserialize, Serialize, Clone)]
    pub struct PriorityParams {
        pub process_name: String,
        pub enable: bool,
    }

    pub fn set_process_priority(process_name: &str, enable: bool) -> String {
        use windows::Win32::Foundation::CloseHandle;
        use windows::Win32::System::Diagnostics::ToolHelp::{
            CreateToolhelp32Snapshot, Process32FirstW, Process32NextW, PROCESSENTRY32W,
            TH32CS_SNAPPROCESS,
        };
        use windows::Win32::System::Threading::{
            OpenProcess, ProcessMemoryPriority, SetPriorityClass, SetProcessInformation,
            ABOVE_NORMAL_PRIORITY_CLASS, MEMORY_PRIORITY_INFORMATION, MEMORY_PRIORITY_NORMAL,
            NORMAL_PRIORITY_CLASS, PROCESS_SET_INFORMATION,
        };

        let priority_class = if enable {
            ABOVE_NORMAL_PRIORITY_CLASS
        } else {
            NORMAL_PRIORITY_CLASS
        };

        unsafe {
            let snapshot = match CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0) {
                Ok(s) => s,
                Err(e) => return format!("Failed to create snapshot: {}", e),
            };

            let mut entry = PROCESSENTRY32W {
                dwSize: std::mem::size_of::<PROCESSENTRY32W>() as u32,
                ..Default::default()
            };

            let mut found = false;

            if Process32FirstW(snapshot, &mut entry).is_ok() {
                loop {
                    let exe_name = String::from_utf16_lossy(&entry.szExeFile);
                    let exe_name = exe_name.trim_end_matches('\0');

                    if exe_name.eq_ignore_ascii_case(process_name) {
                        let process_handle = match OpenProcess(
                            PROCESS_SET_INFORMATION,
                            false,
                            entry.th32ProcessID,
                        ) {
                            Ok(h) => h,
                            Err(e) => {
                                crate::ops::logs::log_message(format!(
                                    "Failed to open process {}: {}",
                                    entry.th32ProcessID, e
                                ));
                                if Process32NextW(snapshot, &mut entry).is_err() {
                                    break;
                                }
                                continue;
                            }
                        };

                        match SetPriorityClass(process_handle, priority_class) {
                            Ok(_) => {
                                found = true;
                                crate::ops::logs::log_message(format!(
                                    "Set priority for {} (PID: {}) to {}",
                                    process_name,
                                    entry.th32ProcessID,
                                    if enable { "above normal" } else { "normal" }
                                ));
                            }
                            Err(e) => {
                                crate::ops::logs::log_message(format!(
                                    "Failed to set priority for {}: {}",
                                    process_name, e
                                ));
                            }
                        }

                        if enable {
                            let memory_priority = MEMORY_PRIORITY_INFORMATION {
                                MemoryPriority: MEMORY_PRIORITY_NORMAL,
                            };
                            if let Err(e) = SetProcessInformation(
                                process_handle,
                                ProcessMemoryPriority,
                                &memory_priority as *const MEMORY_PRIORITY_INFORMATION as _,
                                std::mem::size_of::<MEMORY_PRIORITY_INFORMATION>() as u32,
                            ) {
                                crate::ops::logs::log_message(format!(
                                    "Failed to set memory priority for {}: {}",
                                    process_name, e
                                ));
                            } else {
                                crate::ops::logs::log_message(format!(
                                    "Set memory priority for {} (PID: {}) to normal",
                                    process_name, entry.th32ProcessID
                                ));
                            }
                        }

                        let _ = CloseHandle(process_handle);
                    }

                    if Process32NextW(snapshot, &mut entry).is_err() {
                        break;
                    }
                }
            }

            let _ = CloseHandle(snapshot);

            if found {
                "".to_string()
            } else {
                format!("Process {} not found", process_name)
            }
        }
    }
}
