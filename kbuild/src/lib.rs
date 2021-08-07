mod cli;
mod command;
mod config;

/// Re-export cli struct
pub use cli::Cli;
/// Re-export command
pub use command::{build, configure, error, runner, Command};
/// Re-export kconfig
pub use config::{KConfig, BuildMode, BuildConfig};

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
