use serde::{Deserialize, Serialize};
use std::default::Default;
use std::env;

#[derive(Serialize, Deserialize)]
pub struct KConfig {
    build: BuildConfig,
}

impl KConfig {
    pub fn name() -> String {
        env::var("KCONFIG_NAME").unwrap_or(String::from("kconfig.toml"))
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
    mode: BuildMode,
}

#[derive(Serialize, Deserialize)]
pub enum BuildMode {
    GRUB,
}
