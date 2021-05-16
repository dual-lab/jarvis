#![feature(asm)]
#![no_std] // don't link the Rust standard library

use asm::registers;

/// Main kernel entry point
pub unsafe fn main() {
    registers::cleanup_data_segment();
    asm!("mov dword ptr [0xb8000], 0x2f4b2f4f");
}
