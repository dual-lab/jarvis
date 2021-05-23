use env_logger::init as logger_init;
use exitcode;
use log::{error, debug};
use structopt::StructOpt;

use kbuild::Cli;

fn main() {
    logger_init();
    match Cli::from_args().run() {
        Ok(code) => {
            debug!("command executed succefully {}", code);
            std::process::exit(code);
        }
        Err(e) => {
            error!("command fail: {}", e);
            std::process::exit(exitcode::DATAERR);
        }
    }
}
