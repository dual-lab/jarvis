// Setup kernel stack
global_asm!(include_str!("reservation.S"));

pub fn initialize() {
    unsafe { asm!("mov stack_top, esp", options(nostack)) }
}
