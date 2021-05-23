use anyhow::Result;
use exitcode;
use structopt::StructOpt;
use crate::Command;

#[derive(Debug, StructOpt)]
#[structopt(name = "kbuild")]
/// Kbuild tool used to build run and configure a kernel
///
/// Tool create to build ,run and configure the jarvis kernel.
/// The main command are:
///
///  - build (WIP)
///  - runner (create a iso + run with qemu)
///  - configure (WIP)
pub struct Cli {
    #[structopt(subcommand)]
    cmd: Command,
}

impl Cli {
    pub fn run(&self) -> Result<exitcode::ExitCode> {
        Ok(exitcode::OK)
    }
}
