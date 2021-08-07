use structopt::StructOpt;
use std::path::PathBuf;
use anyhow::Result;
use crate::{KConfig, command};

#[derive(Debug, StructOpt)]
/// Run your kernel into a virt env
///
/// Run the kernel in a virt env.
/// using default qemu program.
pub struct Runner {
    #[structopt(parse(from_os_str))]
    kernel_bin: PathBuf,
}

impl Runner {
    pub fn exec(self, _config: KConfig) -> Result<()> {
        command::build::Build::new(self.kernel_bin).build(_config)?;
        Ok(())
    }
}
