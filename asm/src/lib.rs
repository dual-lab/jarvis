#![feature(asm)]
#![no_std] // don't link the Rust standard library

#[cfg(target_arch = "x86_64")]
mod x86_64; 
#[cfg(target_arch = "x86_64")]
// re-export as without arch dependencies
pub use x86_64::registers;
