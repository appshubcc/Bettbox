use crate::script::{self, ErrorKind, Failure, LogLine, EVALUATE_LIMITS};
use flutter_rust_bridge::frb;

pub struct ScriptLog {
    pub level: String,
    pub text: String,
}

pub enum ScriptErrorKind {
    Syntax,
    Runtime,
    Timeout,
    OutOfMemory,
    Cancelled,
    InvalidInput,
    InvalidOutput,
}

pub struct ScriptError {
    pub kind: ScriptErrorKind,
    pub message: String,
    pub stack: Option<String>,
    pub logs: Vec<ScriptLog>,
}

pub struct ScriptOutput {
    pub logs: Vec<ScriptLog>,
    pub elapsed_ms: u32,
}

fn to_logs(lines: Vec<LogLine>) -> Vec<ScriptLog> {
    lines
        .into_iter()
        .map(|line| ScriptLog {
            level: line.level,
            text: line.text,
        })
        .collect()
}

impl From<Failure> for ScriptError {
    fn from(failure: Failure) -> Self {
        Self {
            kind: match failure.kind {
                ErrorKind::Syntax => ScriptErrorKind::Syntax,
                ErrorKind::Runtime => ScriptErrorKind::Runtime,
                ErrorKind::Timeout => ScriptErrorKind::Timeout,
                ErrorKind::OutOfMemory => ScriptErrorKind::OutOfMemory,
                ErrorKind::Cancelled => ScriptErrorKind::Cancelled,
                ErrorKind::InvalidInput => ScriptErrorKind::InvalidInput,
                ErrorKind::InvalidOutput => ScriptErrorKind::InvalidOutput,
            },
            message: failure.message,
            stack: failure.stack,
            logs: to_logs(failure.logs),
        }
    }
}

fn io_failure(error: std::io::Error) -> ScriptError {
    ScriptError {
        kind: ScriptErrorKind::InvalidInput,
        message: error.to_string(),
        stack: None,
        logs: Vec::new(),
    }
}

#[frb]
pub fn evaluate_script_file(
    script: String,
    input_path: String,
    output_path: String,
    custom_options: Option<String>,
    token: u32,
) -> Result<ScriptOutput, ScriptError> {
    let started = std::time::Instant::now();
    let config = std::fs::read(&input_path).map_err(io_failure)?;
    let evaluation = script::evaluate(
        &script,
        &config,
        custom_options.as_deref(),
        EVALUATE_LIMITS,
        token,
    )?;
    drop(config);
    drop(script);
    std::fs::write(&output_path, evaluation.config).map_err(io_failure)?;
    Ok(ScriptOutput {
        logs: to_logs(evaluation.logs),
        elapsed_ms: started.elapsed().as_millis().min(u32::MAX as u128) as u32,
    })
}

#[frb]
pub fn cancel_script(token: u32) {
    script::cancel(token);
}

#[frb]
pub fn extract_script_options(script: String) -> Result<String, ScriptError> {
    script::extract_options(&script).map_err(ScriptError::from)
}
