use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::VecDeque;
use std::fs::Metadata;
use std::fs::{File, OpenOptions};
use std::io::{BufRead, BufReader, Error, Read};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::{io, thread};
use warp::{Filter, Reply};
use hmac::{Hmac, Mac};
use std::time::{SystemTime, UNIX_EPOCH};
use bytes::Bytes;

#[cfg(windows)]
use windows::Win32::System::Threading::{OpenProcess, SetPriorityClass, ABOVE_NORMAL_PRIORITY_CLASS, NORMAL_PRIORITY_CLASS, PROCESS_SET_INFORMATION};
#[cfg(windows)]
use windows::Win32::Foundation::CloseHandle;

#[allow(unused_imports)]
use fs2::FileExt;

const LISTEN_PORT: u16 = 45678;
const TIME_WINDOW_SECS: u64 = 5;
const MAX_LOG_ENTRIES: usize = 100;
const HASH_BUFFER_SIZE: usize = 65536;

type HmacSha256 = Hmac<Sha256>;

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct StartParams {
    pub path: String,
    pub arg: String,
    pub home_dir: Option<String>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct PriorityParams {
    pub process_name: String,
    pub enable: bool,
}

#[derive(Debug, Clone)]
struct CachedFileHash {
    path: String,
    size: u64,
    modified_nanos: u128,
    hash: String,
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

static LOGS: Lazy<Arc<Mutex<VecDeque<String>>>> =
    Lazy::new(|| Arc::new(Mutex::new(VecDeque::with_capacity(MAX_LOG_ENTRIES))));
pub static PROCESS: Lazy<Arc<Mutex<Option<std::process::Child>>>> =
    Lazy::new(|| Arc::new(Mutex::new(None)));
static AUTH_KEY: Lazy<Arc<Mutex<Option<Vec<u8>>>>> =
    Lazy::new(|| Arc::new(Mutex::new(None)));
static FILE_HASH_CACHE: Lazy<Arc<Mutex<Option<CachedFileHash>>>> =
    Lazy::new(|| Arc::new(Mutex::new(None)));

fn init_auth_key() {
    if let Ok(key_hex) = std::env::var("HELPER_AUTH_KEY") {
        if let Ok(key) = hex::decode(&key_hex) {
            if let Ok(mut auth_key) = AUTH_KEY.lock() {
                *auth_key = Some(key);
                log_message("Auth key initialized".to_string());
            }
        }
    }
}

fn verify_request(timestamp: u64, signature: &str, body: &str) -> bool {
    let key = match AUTH_KEY.lock() {
        Ok(guard) => match guard.as_ref() {
            Some(k) => k.clone(),
            None => {
                log_message("Auth key not initialized, skipping verification".to_string());
                return true;
            }
        },
        Err(_) => return false,
    };

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    if now.abs_diff(timestamp) > TIME_WINDOW_SECS {
        log_message(format!("Request timestamp out of window: {} vs {}", timestamp, now));
        return false;
    }

    let message = format!("{}:{}", timestamp, body);
    let mut mac = match HmacSha256::new_from_slice(&key) {
        Ok(m) => m,
        Err(_) => return false,
    };
    mac.update(message.as_bytes());
    let expected_signature = hex::encode(mac.finalize().into_bytes());

    signature == expected_signature
}

fn start(start_params: StartParams) -> String {
    let file = match OpenOptions::new()
        .read(true)
        .open(&start_params.path)
    {
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

    stop();
    let mut process = PROCESS.lock().unwrap();

    let mut command = Command::new(&start_params.path);
    command.stderr(Stdio::piped()).arg(&start_params.arg);

    if let Some(home_dir) = &start_params.home_dir {
        command.env("SAFE_PATHS", home_dir);
    }

    let result = match command.spawn() {
        Ok(child) => {
            *process = Some(child);

            if let Some(ref mut child) = *process {
                if let Some(stderr) = child.stderr.take() {
                    let reader = io::BufReader::new(stderr);
                    thread::spawn(move || {
                        for line in reader.lines() {
                            match line {
                                Ok(output) => {
                                    log_message(output);
                                }
                                Err(_) => {
                                    break;
                                }
                            }
                        }
                    });
                }
            }
            "".to_string()
        }
        Err(e) => {
            log_message(e.to_string());
            e.to_string()
        }
    };

    result
}

pub fn stop() -> String {
    let mut process = PROCESS.lock().unwrap();
    if let Some(mut child) = process.take() {
        let _ = child.kill();
        let _ = child.wait();
    }
    *process = None;
    "".to_string()
}

#[cfg(windows)]
fn set_process_priority(process_name: &str, enable: bool) -> String {
    use windows::Win32::System::Diagnostics::ToolHelp::{CreateToolhelp32Snapshot, Process32FirstW, Process32NextW, TH32CS_SNAPPROCESS, PROCESSENTRY32W};

    let priority_class = if enable { ABOVE_NORMAL_PRIORITY_CLASS } else { NORMAL_PRIORITY_CLASS };

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
                    let process_handle = match OpenProcess(PROCESS_SET_INFORMATION, false, entry.th32ProcessID) {
                        Ok(h) => h,
                        Err(e) => {
                            log_message(format!("Failed to open process {}: {}", entry.th32ProcessID, e));
                            if Process32NextW(snapshot, &mut entry).is_err() {
                                break;
                            }
                            continue;
                        }
                    };

                    match SetPriorityClass(process_handle, priority_class) {
                        Ok(_) => {
                            found = true;
                            log_message(format!("Set priority for {} (PID: {}) to {}",
                                process_name, entry.th32ProcessID,
                                if enable { "above normal" } else { "normal" }));
                        }
                        Err(e) => {
                            log_message(format!("Failed to set priority for {}: {}", process_name, e));
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

#[cfg(not(windows))]
fn set_process_priority(_process_name: &str, _enable: bool) -> String {
    "Not supported on this platform".to_string()
}

fn log_message(message: String) {
    let mut log_buffer = LOGS.lock().unwrap();
    if log_buffer.len() == MAX_LOG_ENTRIES {
        log_buffer.pop_front();
    }
    log_buffer.push_back(message);
}

fn check_authentication(timestamp: Option<u64>, signature: Option<String>, body: &[u8]) -> bool {
    let auth_enabled = AUTH_KEY.lock().unwrap().is_some();
    if !auth_enabled {
        return true;
    }

    if let (Some(ts), Some(sig)) = (timestamp, signature) {
        let body_str = String::from_utf8_lossy(body);
        if verify_request(ts, &sig, &body_str) {
            return true;
        }
    }
    log_message("Authentication failed".to_string());
    false
}

pub async fn run_service() -> anyhow::Result<()> {
    init_auth_key();

    let api_ping = warp::get().and(warp::path("ping")).map(|| env!("TOKEN"));

    let api_start = warp::post()
        .and(warp::path("start"))
        .and(warp::header::optional::<u64>("X-Timestamp"))
        .and(warp::header::optional::<String>("X-Signature"))
        .and(warp::body::bytes())
        .and_then(|timestamp: Option<u64>, signature: Option<String>, body_bytes: Bytes| async move {
            if !check_authentication(timestamp, signature, &body_bytes) {
                return Ok::<_, warp::Rejection>(warp::reply::with_status(
                    "Unauthorized".to_string(),
                    warp::http::StatusCode::UNAUTHORIZED
                ).into_response());
            }

            let start_params: StartParams = match serde_json::from_slice(&body_bytes) {
                Ok(p) => p,
                Err(_) => return Ok(warp::reply::with_status(
                    "Invalid JSON body".to_string(),
                    warp::http::StatusCode::BAD_REQUEST
                ).into_response()),
            };

            let result = tokio::task::spawn_blocking(move || {
                start(start_params)
            }).await.unwrap_or_else(|e| e.to_string());

            Ok(warp::reply::with_status(result, warp::http::StatusCode::OK).into_response())
        });

    let api_stop = warp::post()
        .and(warp::path("stop"))
        .and(warp::header::optional::<u64>("X-Timestamp"))
        .and(warp::header::optional::<String>("X-Signature"))
        .map(|timestamp: Option<u64>, signature: Option<String>| {
            if !check_authentication(timestamp, signature, b"") {
                return warp::reply::with_status("Unauthorized", warp::http::StatusCode::UNAUTHORIZED).into_response();
            }
            warp::reply::with_status(stop(), warp::http::StatusCode::OK).into_response()
        });

    let api_logs = warp::get()
        .and(warp::path("logs"))
        .and(warp::header::optional::<u64>("X-Timestamp"))
        .and(warp::header::optional::<String>("X-Signature"))
        .map(|timestamp: Option<u64>, signature: Option<String>| {
            if !check_authentication(timestamp, signature, b"") {
                return warp::reply::with_status("Unauthorized".to_string(), warp::http::StatusCode::UNAUTHORIZED).into_response();
            }

            let log_str = LOGS.lock().unwrap()
                .iter()
                .cloned()
                .collect::<Vec<String>>()
                .join("\n");

            warp::reply::with_header(log_str, "Content-Type", "text/plain").into_response()
        });

    let api_set_priority = warp::post()
        .and(warp::path("set_priority"))
        .and(warp::header::optional::<u64>("X-Timestamp"))
        .and(warp::header::optional::<String>("X-Signature"))
        .and(warp::body::bytes())
        .and_then(|timestamp: Option<u64>, signature: Option<String>, body_bytes: Bytes| async move {
            if !check_authentication(timestamp, signature, &body_bytes) {
                return Ok::<_, warp::Rejection>(warp::reply::with_status(
                    "Unauthorized".to_string(),
                    warp::http::StatusCode::UNAUTHORIZED
                ).into_response());
            }

            let priority_params: PriorityParams = match serde_json::from_slice(&body_bytes) {
                Ok(p) => p,
                Err(_) => return Ok(warp::reply::with_status(
                    "Invalid JSON body".to_string(),
                    warp::http::StatusCode::BAD_REQUEST
                ).into_response()),
            };

            let result = tokio::task::spawn_blocking(move || {
                set_process_priority(&priority_params.process_name, priority_params.enable)
            }).await.unwrap_or_else(|e| e.to_string());

            if result.is_empty() {
                Ok(warp::reply::with_status("OK".to_string(), warp::http::StatusCode::OK).into_response())
            } else {
                Ok(warp::reply::with_status(result, warp::http::StatusCode::INTERNAL_SERVER_ERROR).into_response())
            }
        });

    let routes = api_ping
        .or(api_start)
        .or(api_stop)
        .or(api_logs)
        .or(api_set_priority);

    warp::serve(routes)
        .run(([127, 0, 0, 1], LISTEN_PORT))
        .await;

    Ok(())
}
