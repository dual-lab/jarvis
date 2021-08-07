use serde::{Deserialize, Serialize};
use std::default::Default;
use std::env;

#[derive(Serialize, Deserialize)]
pub struct KConfig {
   pub build: BuildConfig,
}

impl KConfig {
    pub fn name() -> String {
        env::var("KCONFIG_NAME").unwrap_or(String::from("kconfig"))
    }
}

impl Default for KConfig {
    fn default() -> Self {
        Self {
            build: BuildConfig {
                mode: BuildMode::GRUB,
            },
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct BuildConfig {
   pub mode: BuildMode,
}

#[derive(Serialize, Deserialize)]
pub enum BuildMode {
    GRUB,
}
