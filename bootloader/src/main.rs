#![no_std] // don't link the Rust standard library
#![no_main] // disable all Rust-level entry points

use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() {
    panic!("Bootloader main is not implmented. jarvis use the grub bootloader");
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
