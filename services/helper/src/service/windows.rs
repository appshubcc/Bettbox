use crate::service::hub::run_service;

use std::ffi::OsString;
use std::time::Duration;

use tokio::runtime::Runtime;

use windows_service::{
    define_windows_service,
    service::{
        ServiceControl, ServiceControlAccept, ServiceExitCode, ServiceState, ServiceStatus,
        ServiceType,
    },
    service_control_handler::{self, ServiceControlHandlerResult},
    service_dispatcher, Result,
};

const DEFAULT_SERVICE_NAME: &str = "BettboxHelperService";

const SERVICE_TYPE: ServiceType = ServiceType::OWN_PROCESS;

fn service_name() -> String {
    std::env::var("HELPER_SERVICE_NAME").unwrap_or_else(|_| {
        std::env::current_exe()
            .ok()
            .and_then(|path| {
                path.file_stem()
                    .map(|stem| stem.to_string_lossy().to_string())
            })
            .filter(|stem| stem.contains("Dev"))
            .unwrap_or_else(|| DEFAULT_SERVICE_NAME.to_string())
    })
}

pub fn main() -> Result<()> {
    start_service()
}

pub fn start_service() -> Result<()> {
    service_dispatcher::start(service_name(), service_entry)
}

define_windows_service!(service_entry, service_main);

pub fn service_main(_arguments: Vec<OsString>) {
    if let Ok(rt) = Runtime::new() {
        rt.block_on(async {
            if let Err(e) = run_windows_service().await {
                let log_name = if service_name().contains("Dev") {
                    "bettbox_dev_helper_error.log"
                } else {
                    "bettbox_helper_error.log"
                };
                let log_path = std::env::temp_dir().join(log_name);
                let ts = std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .map(|d| d.as_secs())
                    .unwrap_or(0);
                let msg = format!("[{}] service error: {}\n", ts, e);
                let _ = std::fs::OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(log_path)
                    .map(|mut f| {
                        use std::io::Write;
                        let _ = f.write_all(msg.as_bytes());
                    });
            }
        });
    }
}

async fn run_windows_service() -> anyhow::Result<()> {
    let service_name = service_name();
    let status_handle = service_control_handler::register(
        service_name,
        move |event| -> ServiceControlHandlerResult {
            match event {
                ServiceControl::Interrogate => ServiceControlHandlerResult::NoError,
                ServiceControl::Stop => {
                    std::thread::spawn(|| {
                        crate::service::hub::stop();
                        std::process::exit(0);
                    });
                    ServiceControlHandlerResult::NoError
                }
                _ => ServiceControlHandlerResult::NotImplemented,
            }
        },
    )?;

    status_handle.set_service_status(ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state: ServiceState::StartPending,
        controls_accepted: ServiceControlAccept::empty(),
        exit_code: ServiceExitCode::Win32(0),
        checkpoint: 0,
        wait_hint: Duration::from_secs(5),
        process_id: None,
    })?;

    status_handle.set_service_status(ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state: ServiceState::Running,
        controls_accepted: ServiceControlAccept::STOP,
        exit_code: ServiceExitCode::Win32(0),
        checkpoint: 0,
        wait_hint: Duration::default(),
        process_id: None,
    })?;

    let result = run_service().await;

    let exit_code = if result.is_ok() {
        ServiceExitCode::Win32(0)
    } else {
        ServiceExitCode::ServiceSpecific(1)
    };
    let _ = status_handle.set_service_status(ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state: ServiceState::Stopped,
        controls_accepted: ServiceControlAccept::empty(),
        exit_code,
        checkpoint: 0,
        wait_hint: Duration::default(),
        process_id: None,
    });

    result
}