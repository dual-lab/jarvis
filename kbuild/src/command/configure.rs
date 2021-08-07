use structopt::StructOpt;
use anyhow::Result;
use crate::KConfig;

#[derive(Debug, StructOpt)]
pub struct Configure {

}

impl Configure {
    pub fn configure(self, _config: KConfig) -> Result<()> {
        Ok(())
    }
}
