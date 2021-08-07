use crate::{KConfig, BuildMode};
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
    pub fn build(self, config: KConfig) -> Result<()> {
        match config.build.mode {
            BuildMode::GRUB => self.grub_mkrescue(&config)
        }
    }
}

impl Build {
    fn grub_mkrescue(&self, _config: &KConfig) -> Result<()> {
        // TODO: check necessary tools
        // TODO: extract working direcotry name + grub menu entry name
        // TODO: create the iso with thr grub_mkrescue command
        // TODO: clean up the working direcotry
        Ok(())
    }
}
