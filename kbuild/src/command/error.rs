use std::error::Error;
use std::fmt::{Display, Formatter, Result};

#[derive(Debug,Clone)]
/// Signal a not found command
pub struct CommandNotFound{
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
    pub fn new(cmd: String)-> Self {
        Self{
            command: cmd
        }
    }
}
