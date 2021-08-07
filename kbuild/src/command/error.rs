use std::error::Error;
use std::fmt::{Display, Formatter, Result};

#[derive(Debug, Clone)]
/// Signal a not found command
pub struct CommandNotFound {
    /// The command not found``
    command: String,
}

impl Error for CommandNotFound {}

impl Display for CommandNotFound {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "Command {} not found", self.command)
    }
}

impl CommandNotFound {
    pub fn new(cmd: String) -> Self {
        Self { command: cmd }
    }
}

#[derive(Debug, Clone)]
/// Signal that a step of the process is failed
pub struct StepUnsuccefull {
    scope: StepScope,
}

impl Error for StepUnsuccefull {}

impl Display for StepUnsuccefull {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "Step {} failed", self.scope)
    }
}

impl StepUnsuccefull {
    pub fn new(scope: StepScope) -> Self {
        Self {
            scope
        }
    }
}

#[derive(Debug, Clone, Copy)]
/// Possible step error scope
pub enum StepScope {
    BUILD,
    CONFIGURE,
    RUN,
}

impl Display for StepScope {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        let scope_desc = match self {
            StepScope::RUN => "RUNNER",
            StepScope::CONFIGURE => "CONFIGURE",
            StepScope::BUILD => "BUILD",
        };
        write!(f, "{}", scope_desc)
    }
}

#[derive(Debug, Clone)]
pub struct SegmentationFault;

impl Error for SegmentationFault {}

impl Display for SegmentationFault {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "Segmantation fault: some went wrong")
    }
}

