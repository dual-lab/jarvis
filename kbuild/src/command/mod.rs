pub mod runner;
pub mod configure;
pub mod build;

use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub enum Command {
    Build(build::Build),
    Runner(runner::Runner),
    Configure(configure::Configure)
}
