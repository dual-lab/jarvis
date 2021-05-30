use std::env;
use std::default::Default;
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct KConfig {

}

impl KConfig {
    pub fn name() -> String {
        env::var("KCONFIG_NAME").unwrap_or(String::from("kconfig.toml"))
    }
}

impl Default for KConfig {
    fn default() -> Self {
        Self {}
    }
}

