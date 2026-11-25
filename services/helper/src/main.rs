#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
use crate::service::hub::run_service;
#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
use tokio::runtime::Runtime;

#[cfg(windows)]
mod firewall;
mod ipc;
mod ops;
mod rpc;
mod service;

#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub fn main() -> windows_service::Result<()> {
    service::windows::main()
}

#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
fn main() {
    if let Ok(rt) = Runtime::new() {
        rt.block_on(async {
            let _ = run_service().await;
        });
    }
}
