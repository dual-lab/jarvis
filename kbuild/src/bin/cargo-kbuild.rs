use anyhow::Context;
use confy;
use env_logger::init as logger_init;
use exitcode;
use log::{debug, error};
use structopt::StructOpt;

use kbuild::{Cli, KConfig};

fn main() {
    logger_init();
    let config_name = KConfig::name();
    let kconfig: KConfig = confy::load(config_name.as_str())
        .with_context(|| format!("Error on load config file {}", config_name))
        .unwrap();
    match Cli::from_args().run(kconfig) {
        Ok(_) => {
            debug!("command executed succefully {}", exitcode::OK);
            std::process::exit(exitcode::OK);
        }
        Err(e) => {
            error!("command fail: {}", e);
            std::process::exit(exitcode::DATAERR);
        }
    }
}
