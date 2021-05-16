// asm inline registers function

//! This module containts inline assembly function
//! to handle operation on registers

/// Clean up all data segment registers
#[inline(always)]
pub unsafe fn cleanup_data_segment() {
    asm!(
        "mov ax, 0x0",
        "mov ss, ax",
        "mov ds, ax",
        "mov es, ax",
        "mov fs, ax",
        "mov gs, ax",
        out("ax") _);
}
