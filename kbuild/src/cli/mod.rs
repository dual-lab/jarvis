use crate::{Command, KConfig};
use anyhow::{bail, Result};
use structopt::StructOpt;

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
    pub fn run(self, config: KConfig) -> Result<()> {
        match self.cmd {
            Command::Runner(c) => c.exec(config),
            Command::Configure(c) => c.run(),
            _ => bail!("Command not supported"),
        }
    }
}
