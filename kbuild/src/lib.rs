mod cli;
mod command;
/// Re-export cli struct
pub use cli::Cli;
/// Re-export command
pub use command::{Command};

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
