use crate::{Command, KConfig};
use anyhow::Result;
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
#[structopt(name = "kbuild")]
/// Kbuild tool used to build run and configure a kernel
///
/// Tool create to build ,run and configure the jarvis kernel.
/// The main command are:
///
///  - build (create a iso)
///  - runner (run with qemu)
///  - configure (configure the kernel)
pub struct Cli {
    #[structopt(subcommand)]
    cmd: Command,
}

impl Cli {
    pub fn run(self, config: KConfig) -> Result<()> {
        match self.cmd {
            Command::Runner(c) => c.exec(config),
            Command::Configure(c) => c.configure(config),
            Command::Build(c) => c.build(config),
            // _ => bail!("Command not supported"),
        }
    }
}
