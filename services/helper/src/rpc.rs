use crate::ops;

use hmac::{Hmac, Mac};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sha2::Sha256;
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

const PROTOCOL_VERSION: u32 = 1;
const TIME_WINDOW_SECS: u64 = 5;

type HmacSha256 = Hmac<Sha256>;

static AUTH_KEY: Lazy<Arc<Mutex<Option<Vec<u8>>>>> = Lazy::new(|| Arc::new(Mutex::new(None)));

pub fn init_auth_key() {
    let key_hex = match std::env::var("HELPER_AUTH_KEY") {
        Ok(v) => v,
        Err(_) => {
            ops::logs::log_message(
                "HELPER_AUTH_KEY not set, helper requests will fail auth".to_string(),
            );
            return;
        }
    };

    match hex::decode(&key_hex) {
        Ok(key) => {
            if let Ok(mut auth_key) = AUTH_KEY.lock() {
                *auth_key = Some(key);
                ops::logs::log_message("Auth key initialized".to_string());
            }
        }
        Err(e) => {
            ops::logs::log_message(format!("HELPER_AUTH_KEY is invalid hex: {}", e));
        }
    }

    std::env::remove_var("HELPER_AUTH_KEY");
}

pub async fn handle_payload(payload: &str) -> String {
    match HelperRequest::decode(payload) {
        Ok(request) => handle_request(request).await.encode(),
        Err(e) => {
            HelperResponse::error("", HelperError::new("INVALID_REQUEST", e.to_string())).encode()
        }
    }
}

async fn handle_request(request: HelperRequest) -> HelperResponse {
    if request.version != PROTOCOL_VERSION {
        return HelperResponse::error(
            &request.id,
            HelperError::new("UNSUPPORTED_VERSION", "Unsupported helper protocol version"),
        );
    }

    let auth_payload = format!("{}:{}:{}", request.version, request.method, request.body);
    if !verify_request(
        request.auth.timestamp,
        &request.auth.signature,
        &auth_payload,
    ) {
        ops::logs::log_message("Authentication failed".to_string());
        return HelperResponse::error(
            &request.id,
            HelperError::new("UNAUTHORIZED", "Unauthorized helper request"),
        );
    }

    match request.method.as_str() {
        "helper.ping" => HelperResponse::success(&request.id, serde_json::json!(env!("TOKEN"))),
        "helper.logs" => HelperResponse::success(&request.id, serde_json::json!(ops::logs::logs())),
        "helper.stop_service" => {
            ops::logs::log_message(format!(
                "Received helper.stop_service request [{}]",
                request.id
            ));
            std::thread::spawn(|| {
                std::thread::sleep(std::time::Duration::from_millis(100));
                ops::core::stop_core();
                std::process::exit(0);
            });
            HelperResponse::empty_success(&request.id)
        }
        "core.start" => {
            ops::logs::log_message(format!("Received core.start request [{}]", request.id));
            handle_core_start(&request).await
        }
        "core.stop" => result_to_response(&request.id, ops::core::stop_core(), "CORE_STOP_FAILED"),
        "process.set_priority" => handle_set_priority(&request).await,
        _ => HelperResponse::error(
            &request.id,
            HelperError::new(
                "UNKNOWN_METHOD",
                format!("Unknown method: {}", request.method),
            ),
        ),
    }
}

async fn handle_core_start(request: &HelperRequest) -> HelperResponse {
    let params = match serde_json::from_str::<ops::core::StartParams>(&request.body) {
        Ok(params) => params,
        Err(e) => {
            return HelperResponse::error(
                &request.id,
                HelperError::new("INVALID_BODY", e.to_string()),
            )
        }
    };

    let result = tokio::task::spawn_blocking(move || ops::core::start_core(params))
        .await
        .unwrap_or_else(|e| e.to_string());
    result_to_response(&request.id, result, "CORE_START_FAILED")
}

async fn handle_set_priority(request: &HelperRequest) -> HelperResponse {
    let params = match serde_json::from_str::<ops::process::PriorityParams>(&request.body) {
        Ok(params) => params,
        Err(e) => {
            return HelperResponse::error(
                &request.id,
                HelperError::new("INVALID_BODY", e.to_string()),
            )
        }
    };

    let result = tokio::task::spawn_blocking(move || {
        ops::process::set_process_priority(&params.process_name, params.enable)
    })
    .await
    .unwrap_or_else(|e| e.to_string());
    result_to_response(&request.id, result, "PROCESS_PRIORITY_FAILED")
}

fn result_to_response(id: &str, result: String, code: &str) -> HelperResponse {
    if result.is_empty() {
        HelperResponse::empty_success(id)
    } else {
        HelperResponse::error(id, HelperError::new(code, result))
    }
}

fn verify_request(timestamp: u64, signature: &str, body: &str) -> bool {
    let key = match AUTH_KEY.lock() {
        Ok(guard) => match guard.as_ref() {
            Some(k) => k.clone(),
            None => return false,
        },
        Err(_) => return false,
    };

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    if now.abs_diff(timestamp) > TIME_WINDOW_SECS {
        ops::logs::log_message(format!(
            "Request timestamp out of window: {} vs {}",
            timestamp, now
        ));
        return false;
    }

    let message = format!("{}:{}", timestamp, body);
    let mut mac = match HmacSha256::new_from_slice(&key) {
        Ok(m) => m,
        Err(_) => return false,
    };
    mac.update(message.as_bytes());

    // Constant-time verification: decode the hex signature and let the MAC
    // compare it, avoiding the timing side-channel of `&str` equality.
    match hex::decode(signature) {
        Ok(provided) => mac.verify_slice(&provided).is_ok(),
        Err(_) => false,
    }
}

#[derive(Debug, Deserialize)]
struct HelperRequest {
    version: u32,
    id: String,
    method: String,
    #[serde(default)]
    body: String,
    auth: HelperAuth,
}

#[derive(Debug, Deserialize)]
struct HelperAuth {
    timestamp: u64,
    signature: String,
}

impl HelperRequest {
    fn decode(payload: &str) -> serde_json::Result<Self> {
        serde_json::from_str(payload)
    }
}

#[derive(Debug, Serialize)]
struct HelperResponse {
    version: u32,
    id: String,
    ok: bool,
    data: Option<serde_json::Value>,
    error: Option<HelperError>,
}

impl HelperResponse {
    fn success(id: &str, data: serde_json::Value) -> Self {
        Self {
            version: PROTOCOL_VERSION,
            id: id.to_string(),
            ok: true,
            data: Some(data),
            error: None,
        }
    }

    fn empty_success(id: &str) -> Self {
        Self::success(id, serde_json::Value::Null)
    }

    fn error(id: &str, error: HelperError) -> Self {
        Self {
            version: PROTOCOL_VERSION,
            id: id.to_string(),
            ok: false,
            data: None,
            error: Some(error),
        }
    }

    fn encode(&self) -> String {
        serde_json::to_string(self).unwrap_or_else(|e| {
            format!(
                r#"{{"version":{},"id":"{}","ok":false,"data":null,"error":{{"code":"ENCODE_ERROR","message":"{}"}}}}"#,
                PROTOCOL_VERSION,
                self.id,
                e
            )
        })
    }
}

#[derive(Debug, Serialize)]
struct HelperError {
    code: String,
    message: String,
}

impl HelperError {
    fn new(code: &str, message: impl Into<String>) -> Self {
        Self {
            code: code.to_string(),
            message: message.into(),
        }
    }
}
