mod console;
mod convert;

pub use console::LogLine;

use console::{LogBuffer, SharedLogs};
use rquickjs::{CatchResultExt, CaughtError, Context, Function, Runtime, Value};
use serde_json::{Map, Value as Json};
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex, OnceLock};
use std::time::{Duration, Instant};

const ENTRY: &str = "main";

#[derive(Clone, Copy)]
pub struct Limits {
    pub timeout: Duration,
    pub memory: usize,
    pub stack: usize,
}

pub const EVALUATE_LIMITS: Limits = Limits {
    timeout: Duration::from_secs(10),
    memory: 128 * 1024 * 1024,
    stack: 512 * 1024,
};

pub const EXTRACT_LIMITS: Limits = Limits {
    timeout: Duration::from_secs(2),
    memory: 32 * 1024 * 1024,
    stack: 512 * 1024,
};

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum ErrorKind {
    Syntax,
    Runtime,
    Timeout,
    OutOfMemory,
    Cancelled,
    InvalidInput,
    InvalidOutput,
}

#[derive(Debug)]
pub struct Failure {
    pub kind: ErrorKind,
    pub message: String,
    pub stack: Option<String>,
    pub logs: Vec<LogLine>,
}

impl Failure {
    fn new(kind: ErrorKind, message: impl Into<String>) -> Self {
        Self {
            kind,
            message: message.into(),
            stack: None,
            logs: Vec::new(),
        }
    }
}

pub struct Evaluation {
    pub config: Vec<u8>,
    pub logs: Vec<LogLine>,
}

fn cancellations() -> &'static Mutex<HashMap<u32, Arc<AtomicBool>>> {
    static CANCELLATIONS: OnceLock<Mutex<HashMap<u32, Arc<AtomicBool>>>> = OnceLock::new();
    CANCELLATIONS.get_or_init(Default::default)
}

struct Registration {
    token: u32,
    flag: Arc<AtomicBool>,
}

impl Registration {
    fn new(token: u32) -> Self {
        let flag = Arc::new(AtomicBool::new(false));
        if let Ok(mut map) = cancellations().lock() {
            map.insert(token, flag.clone());
        }
        Self { token, flag }
    }
}

impl Drop for Registration {
    fn drop(&mut self) {
        if let Ok(mut map) = cancellations().lock() {
            map.remove(&self.token);
        }
    }
}

pub fn cancel(token: u32) {
    if let Ok(map) = cancellations().lock() {
        if let Some(flag) = map.get(&token) {
            flag.store(true, Ordering::Relaxed);
        }
    }
}

struct Sandbox {
    context: Context,
    cancelled: Arc<AtomicBool>,
    timed_out: Arc<AtomicBool>,
}

impl Sandbox {
    fn new(limits: Limits, cancelled: Arc<AtomicBool>) -> Result<Self, Failure> {
        let runtime = Runtime::new().map_err(internal)?;
        runtime.set_memory_limit(limits.memory);
        runtime.set_max_stack_size(limits.stack);
        let deadline = Instant::now() + limits.timeout;
        let timed_out = Arc::new(AtomicBool::new(false));
        let (expired, stop) = (timed_out.clone(), cancelled.clone());
        runtime.set_interrupt_handler(Some(Box::new(move || {
            if stop.load(Ordering::Relaxed) {
                return true;
            }
            if Instant::now() >= deadline {
                expired.store(true, Ordering::Relaxed);
                return true;
            }
            false
        })));
        let context = Context::full(&runtime).map_err(internal)?;
        Ok(Self {
            context,
            cancelled,
            timed_out,
        })
    }

    fn classify(&self, error: CaughtError<'_>, phase: ErrorKind) -> Failure {
        if self.cancelled.load(Ordering::Relaxed) {
            return Failure::new(ErrorKind::Cancelled, "script was cancelled");
        }
        if self.timed_out.load(Ordering::Relaxed) {
            return Failure::new(ErrorKind::Timeout, "script timed out");
        }
        match error {
            CaughtError::Exception(exception) => {
                let message = exception.message().unwrap_or_else(|| exception.to_string());
                if message == "out of memory" {
                    return Failure::new(ErrorKind::OutOfMemory, "script ran out of memory");
                }
                let stack = exception
                    .stack()
                    .map(|stack| stack.trim().to_owned())
                    .filter(|stack| !stack.is_empty());
                Failure {
                    kind: phase,
                    message,
                    stack,
                    logs: Vec::new(),
                }
            }
            CaughtError::Value(value) if value.is_null() => {
                Failure::new(ErrorKind::OutOfMemory, "script ran out of memory")
            }
            other => Failure::new(phase, other.to_string()),
        }
    }
}

fn internal(error: rquickjs::Error) -> Failure {
    Failure::new(ErrorKind::Runtime, error.to_string())
}

fn normalize(input: Json) -> Result<Map<String, Json>, Failure> {
    let Json::Object(source) = input else {
        return Err(Failure::new(
            ErrorKind::InvalidInput,
            "profile is not a JSON object",
        ));
    };
    let mut config = Map::with_capacity(source.len() + 1);
    for (key, value) in source {
        if key == "rule" {
            config.insert("rules".to_owned(), value);
        } else {
            config.insert(key, value);
        }
    }
    let providers = config
        .entry("proxy-providers")
        .or_insert_with(|| Json::Object(Map::new()));
    if providers.is_null() {
        *providers = Json::Object(Map::new());
    }
    Ok(config)
}

pub fn evaluate(
    script: &str,
    config: &[u8],
    custom_options: Option<&str>,
    limits: Limits,
    token: u32,
) -> Result<Evaluation, Failure> {
    let input: Json = serde_json::from_slice(config)
        .map_err(|error| Failure::new(ErrorKind::InvalidInput, error.to_string()))?;
    let input = Json::Object(normalize(input)?);
    let custom: Option<Json> = match custom_options {
        Some(text) => Some(
            serde_json::from_str(text)
                .map_err(|error| Failure::new(ErrorKind::InvalidInput, error.to_string()))?,
        ),
        None => None,
    };

    let registration = Registration::new(token);
    let sandbox = Sandbox::new(limits, registration.flag.clone())?;
    let logs: SharedLogs = Rc::new(RefCell::new(LogBuffer::default()));
    let result = sandbox.context.with(|ctx| {
        console::install(&ctx, Some(logs.clone()))
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Runtime))?;
        let source = format!(
            "(function(__config, __custom) {{ {script}\n;if (__custom && typeof ruleOptionsEnable !== 'undefined') Object.assign(ruleOptionsEnable, __custom);\nreturn {ENTRY}(__config); }})"
        );
        let entry: Function = ctx
            .eval(source)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Syntax))?;
        let config_value = convert::to_js(&ctx, &input, 0)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::InvalidInput))?;
        let custom_value = match &custom {
            Some(json) => convert::to_js(&ctx, json, 0)
                .catch(&ctx)
                .map_err(|error| sandbox.classify(error, ErrorKind::InvalidInput))?,
            None => Value::new_null(ctx.clone()),
        };
        let result: Value = entry
            .call((config_value, custom_value))
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Runtime))?;
        let result = match result.as_promise() {
            Some(promise) => promise.finish::<Value>().catch(&ctx).map_err(|error| {
                if matches!(
                    error,
                    CaughtError::Error(rquickjs::Error::WouldBlock)
                ) {
                    return Failure::new(
                        ErrorKind::Runtime,
                        format!("{ENTRY}() returned a Promise that did not settle"),
                    );
                }
                sandbox.classify(error, ErrorKind::Runtime)
            })?,
            None => result,
        };
        if !result.is_object() || result.is_array() {
            return Ok(None);
        }
        convert::from_js(&result, 0)
            .catch(&ctx)
            .map(Some)
            .map_err(|error| sandbox.classify(error, ErrorKind::InvalidOutput))
    });
    let logs = logs.borrow_mut().take();
    match result {
        Ok(output) => {
            let config = serde_json::to_vec(output.as_ref().unwrap_or(&input))
                .map_err(|error| Failure::new(ErrorKind::InvalidOutput, error.to_string()))?;
            Ok(Evaluation { config, logs })
        }
        Err(mut failure) => {
            failure.logs = logs;
            Err(failure)
        }
    }
}

const EXTRACT_OPTIONS: &str = r#"
;var __options = typeof ruleOptionsEnable !== 'undefined' && ruleOptionsEnable && typeof ruleOptionsEnable === 'object' ? ruleOptionsEnable : {};
var __icons = {};
if (typeof serviceConfigs !== 'undefined' && Array.isArray(serviceConfigs)) {
  for (var __i = 0; __i < serviceConfigs.length; __i++) {
    var __service = serviceConfigs[__i];
    if (__service && __service.name && typeof __service.icon === 'string') {
      __icons[__service.name] = __service.icon;
    }
  }
}
var __groups = [];
if (typeof Compatible_With_Bettbox !== 'undefined' && Compatible_With_Bettbox && Array.isArray(Compatible_With_Bettbox.policyGroupOptions)) {
  var __declared = Compatible_With_Bettbox.policyGroupOptions;
  for (var __j = 0; __j < __declared.length; __j++) {
    if (typeof __declared[__j] === 'string') {
      __groups.push(__declared[__j]);
    }
  }
}
var __result = { options: __options, icons: __icons, policyGroupOptions: __groups };
if (typeof Compatible_With_Bettbox !== 'undefined' && Compatible_With_Bettbox && Compatible_With_Bettbox.nodeRegions && typeof Compatible_With_Bettbox.nodeRegions === 'object') {
  __result.nodeRegions = Compatible_With_Bettbox.nodeRegions;
}
return JSON.stringify(__result);
"#;

pub fn extract_options(script: &str) -> Result<String, Failure> {
    let sandbox = Sandbox::new(EXTRACT_LIMITS, Arc::new(AtomicBool::new(false)))?;
    sandbox.context.with(|ctx| {
        console::install(&ctx, None)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Runtime))?;
        let source = format!("(function() {{ {script}\n{EXTRACT_OPTIONS} }})()");
        let result: Value = ctx
            .eval(source)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Runtime))?;
        match result.as_string() {
            Some(text) => text
                .to_string()
                .map_err(|error| Failure::new(ErrorKind::InvalidOutput, error.to_string())),
            None => Err(Failure::new(
                ErrorKind::InvalidOutput,
                "script options are not available",
            )),
        }
    })
}

#[cfg(test)]
mod tests;
