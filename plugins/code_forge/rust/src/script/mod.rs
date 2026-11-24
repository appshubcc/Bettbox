mod console;

pub use console::LogLine;

use console::{LogBuffer, SharedLogs};
use rquickjs::{CatchResultExt, CaughtError, Context, Ctx, Function, Object, Runtime, Value};
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex, OnceLock};
use std::time::{Duration, Instant};

const ENTRY: &str = "main";
const BIGINT_TO_JSON: &str = "var __bigint = Object.getPrototypeOf(0n); if (!Object.prototype.hasOwnProperty.call(__bigint, 'toJSON')) Object.defineProperty(__bigint, 'toJSON', { value: function () { return null; }, configurable: true, writable: true });";

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

fn parse_profile<'js>(ctx: &Ctx<'js>, config: &[u8]) -> rquickjs::Result<Option<Value<'js>>> {
    let value = ctx.json_parse(config)?;
    let Some(object) = value.as_object() else {
        return Ok(None);
    };
    if value.is_array() || value.is_function() {
        return Ok(None);
    }
    if object.contains_key("rule")? {
        let rule: Value = object.get("rule")?;
        if !object.contains_key("rules")? {
            object.set("rules", rule)?;
        }
        object.remove("rule")?;
    }
    let providers: Value = object.get("proxy-providers")?;
    if providers.is_undefined() || providers.is_null() {
        object.set("proxy-providers", Object::new(ctx.clone())?)?;
    }
    Ok(Some(value))
}

pub fn evaluate(
    script: &str,
    config: &[u8],
    custom_options: Option<&str>,
    limits: Limits,
    token: u32,
) -> Result<Evaluation, Failure> {
    let registration = Registration::new(token);
    let sandbox = Sandbox::new(limits, registration.flag.clone())?;
    let logs: SharedLogs = Rc::new(RefCell::new(LogBuffer::default()));
    let result = sandbox.context.with(|ctx| {
        console::install(&ctx, Some(logs.clone()))
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Runtime))?;
        let config_value = parse_profile(&ctx, config)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::InvalidInput))?
            .ok_or_else(|| Failure::new(ErrorKind::InvalidInput, "profile is not a JSON object"))?;
        let custom_value = match custom_options {
            Some(text) => ctx
                .json_parse(text)
                .catch(&ctx)
                .map_err(|error| sandbox.classify(error, ErrorKind::InvalidInput))?,
            None => Value::new_null(ctx.clone()),
        };
        let source = format!(
            "(function(__config, __custom) {{ {script}\n;if (__custom && typeof ruleOptionsEnable !== 'undefined') Object.assign(ruleOptionsEnable, __custom);\nreturn {ENTRY}(__config); }})"
        );
        let entry: Function = ctx
            .eval(source)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::Syntax))?;
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
        let target = if result.is_object() && !result.is_array() && !result.is_function() {
            result
        } else {
            parse_profile(&ctx, config)
                .catch(&ctx)
                .map_err(|error| sandbox.classify(error, ErrorKind::InvalidInput))?
                .ok_or_else(|| {
                    Failure::new(ErrorKind::InvalidInput, "profile is not a JSON object")
                })?
        };
        ctx.eval::<(), _>(BIGINT_TO_JSON)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::InvalidOutput))?;
        let output = ctx
            .json_stringify(target)
            .catch(&ctx)
            .map_err(|error| sandbox.classify(error, ErrorKind::InvalidOutput))?
            .ok_or_else(|| {
                Failure::new(ErrorKind::InvalidOutput, "script output could not be serialized")
            })?;
        output
            .to_string()
            .map(String::into_bytes)
            .map_err(|error| Failure::new(ErrorKind::InvalidOutput, error.to_string()))
    });
    let logs = logs.borrow_mut().take();
    match result {
        Ok(config) => Ok(Evaluation { config, logs }),
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
