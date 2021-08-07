use crate::KConfig;
use anyhow::Result;
use std::path::PathBuf;
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
/// Pack the kernel image into a iso file
///
/// Take in input the kernel image and create
/// an iso file with bootloader.
pub struct Build {
    #[structopt(parse(from_os_str))]
    kernel_bin: PathBuf,
}

impl Build {
    pub fn new(bin_path: PathBuf) -> Self {
        Self {
            kernel_bin: bin_path,
        }
    }
    /// Build of iso pack flow
    pub fn build(self, _config: KConfig) -> Result<()> {
        Ok(())
    }
}
