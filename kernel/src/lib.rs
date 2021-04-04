#![feature(asm)]
#![no_std] // don't link the Rust standard library

pub fn it_works() {
    unsafe { asm!("mov dword ptr [0xb8000], 0x2f4b2f4f"); }
}
