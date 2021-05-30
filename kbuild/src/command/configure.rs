use structopt::StructOpt;
use anyhow::Result;

#[derive(Debug, StructOpt)]
pub struct Configure {

}

impl Configure {
    pub fn run(self) -> Result<()> {
        Ok(())
    }
}
