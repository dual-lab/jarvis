#![feature(global_asm)]
#![feature(lang_items)]
#![feature(asm)]
#![no_std] // don't link the Rust standard library
#![no_main] // disable all Rust-level entry points

#[cfg(not(target_os = "none"))]
compile_error!("The boot binary must be compiled for the custom jaris target");


mod multiboot_header;
mod stage;

use core::panic::PanicInfo;
use kernel;
/// This function is called on panic.
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[no_mangle] // don't mangle the name of this function
pub extern "C" fn _boot() -> ! {
    kernel::it_works();
    loop {}
}
