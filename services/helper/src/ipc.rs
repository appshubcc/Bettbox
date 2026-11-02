pub mod named_pipe {
    use tokio::net::windows::named_pipe::{PipeMode, ServerOptions};

    use crate::ipc::frame::{read_frame, write_frame};
    use crate::rpc;

    pub async fn run(pipe_name: &str) -> anyhow::Result<()> {
        let pipe_security = PipeSecurityAttributes::new()?;
        let mut first_instance = true;

        loop {
            let mut pipe = match ServerOptions::new()
                .first_pipe_instance(first_instance)
                .pipe_mode(PipeMode::Byte)
                .reject_remote_clients(true)
                .create_with_security_attributes(pipe_name, &pipe_security)
            {
                Ok(pipe) => pipe,
                Err(e) => {
                    // The first instance must be created with first_pipe_instance(true)
                    // to guarantee no other process squatted the pipe name; if that
                    // fails, abort instead of weakening the guarantee. Later failures
                    // are transient, so log and retry rather than stop the service.
                    if first_instance {
                        return Err(e.into());
                    }
                    crate::ops::logs::log_message(format!("Failed to create pipe instance: {}", e));
                    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
                    continue;
                }
            };
            first_instance = false;

            if let Err(e) = pipe.connect().await {
                crate::ops::logs::log_message(format!("IPC connect error: {}", e));
                tokio::time::sleep(std::time::Duration::from_millis(100)).await;
                continue;
            }

            tokio::spawn(async move {
                if let Err(e) = handle_connection(&mut pipe).await {
                    crate::ops::logs::log_message(format!("IPC connection error: {}", e));
                }
            });
        }
    }

    async fn handle_connection(
        pipe: &mut tokio::net::windows::named_pipe::NamedPipeServer,
    ) -> anyhow::Result<()> {
        if !verify_client_process(pipe) {
            crate::ops::logs::log_message("Rejected unauthorized pipe client process".to_string());
            return Ok(());
        }
        if let Some(request) = read_frame(pipe).await? {
            let response = rpc::handle_payload(&request).await;
            write_frame(pipe, &response).await?;
        }
        Ok(())
    }

    fn verify_client_process(pipe: &tokio::net::windows::named_pipe::NamedPipeServer) -> bool {
        use std::os::windows::io::AsRawHandle;
        use windows::core::PWSTR;
        use windows::Win32::Foundation::{CloseHandle, HANDLE};
        use windows::Win32::System::Pipes::GetNamedPipeClientProcessId;
        use windows::Win32::System::Threading::{
            OpenProcess, QueryFullProcessImageNameW, PROCESS_NAME_WIN32,
            PROCESS_QUERY_LIMITED_INFORMATION,
        };

        if crate::ops::core::is_dev_mode() {
            return true;
        }
        let mut pid = 0u32;
        let mut buffer = [0u16; 1024];
        let mut size = buffer.len() as u32;
        unsafe {
            let pipe_handle = HANDLE(pipe.as_raw_handle() as isize);
            if GetNamedPipeClientProcessId(pipe_handle, &mut pid).is_err() {
                return false;
            }
            let Ok(process) = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pid) else {
                return false;
            };
            let queried = QueryFullProcessImageNameW(
                process,
                PROCESS_NAME_WIN32,
                PWSTR(buffer.as_mut_ptr()),
                &mut size,
            );
            let _ = CloseHandle(process);
            if queried.is_err() {
                return false;
            }
        }
        let client = std::path::PathBuf::from(String::from_utf16_lossy(&buffer[..size as usize]));
        let Ok(helper) = std::env::current_exe() else {
            return false;
        };
        let same_dir = match (client.parent(), helper.parent()) {
            (Some(c), Some(h)) => c.as_os_str().eq_ignore_ascii_case(h.as_os_str()),
            _ => false,
        };
        same_dir
            && client
                .file_name()
                .is_some_and(|name| name.eq_ignore_ascii_case("Bettbox.exe"))
    }

    struct PipeSecurityAttributes {
        attributes: windows::Win32::Security::SECURITY_ATTRIBUTES,
        security_descriptor: windows::Win32::Security::PSECURITY_DESCRIPTOR,
    }

    impl PipeSecurityAttributes {
        fn new() -> anyhow::Result<Self> {
            use windows::core::w;
            use windows::Win32::Security::Authorization::ConvertStringSecurityDescriptorToSecurityDescriptorW;
            use windows::Win32::Security::{PSECURITY_DESCRIPTOR, SECURITY_ATTRIBUTES};

            let mut security_descriptor = PSECURITY_DESCRIPTOR::default();
            unsafe {
                ConvertStringSecurityDescriptorToSecurityDescriptorW(
                    w!("D:P(A;;GRGW;;;SY)(A;;GRGW;;;BA)(A;;GRGW;;;AU)(A;;GRGW;;;IU)"),
                    1,
                    &mut security_descriptor,
                    None,
                )?;
            }

            Ok(Self {
                attributes: SECURITY_ATTRIBUTES {
                    nLength: std::mem::size_of::<SECURITY_ATTRIBUTES>() as u32,
                    lpSecurityDescriptor: security_descriptor.0,
                    bInheritHandle: windows::Win32::Foundation::BOOL(0),
                },
                security_descriptor,
            })
        }

        fn as_mut_ptr(&self) -> *mut std::ffi::c_void {
            (&self.attributes as *const windows::Win32::Security::SECURITY_ATTRIBUTES)
                as *mut std::ffi::c_void
        }
    }

    impl Drop for PipeSecurityAttributes {
        fn drop(&mut self) {
            unsafe {
                let _ = windows::Win32::Foundation::LocalFree(windows::Win32::Foundation::HLOCAL(
                    self.security_descriptor.0,
                ));
            }
        }
    }

    trait ServerOptionsSecurityExt {
        fn create_with_security_attributes(
            &self,
            pipe_name: &str,
            security_attributes: &PipeSecurityAttributes,
        ) -> std::io::Result<tokio::net::windows::named_pipe::NamedPipeServer>;
    }

    impl ServerOptionsSecurityExt for ServerOptions {
        fn create_with_security_attributes(
            &self,
            pipe_name: &str,
            security_attributes: &PipeSecurityAttributes,
        ) -> std::io::Result<tokio::net::windows::named_pipe::NamedPipeServer> {
            unsafe {
                self.create_with_security_attributes_raw(
                    pipe_name,
                    security_attributes.as_mut_ptr(),
                )
            }
        }
    }
}

mod frame {
    use tokio::io::{AsyncRead, AsyncReadExt, AsyncWrite, AsyncWriteExt};

    const MAX_FRAME_SIZE: usize = 1024 * 1024;

    pub async fn read_frame<T>(stream: &mut T) -> anyhow::Result<Option<String>>
    where
        T: AsyncRead + Unpin,
    {
        let mut header = [0u8; 4];
        match stream.read_exact(&mut header).await {
            Ok(_) => {}
            Err(e) if e.kind() == std::io::ErrorKind::UnexpectedEof => return Ok(None),
            Err(e) => return Err(e.into()),
        }

        let length = u32::from_le_bytes(header) as usize;
        if length > MAX_FRAME_SIZE {
            anyhow::bail!("frame too large: {}", length);
        }

        let mut payload = vec![0u8; length];
        stream.read_exact(&mut payload).await?;
        Ok(Some(String::from_utf8(payload)?))
    }

    pub async fn write_frame<T>(stream: &mut T, payload: &str) -> anyhow::Result<()>
    where
        T: AsyncWrite + Unpin,
    {
        let bytes = payload.as_bytes();
        if bytes.len() > MAX_FRAME_SIZE {
            anyhow::bail!("frame too large: {}", bytes.len());
        }
        stream
            .write_all(&(bytes.len() as u32).to_le_bytes())
            .await?;
        stream.write_all(bytes).await?;
        stream.flush().await?;
        Ok(())
    }
}
