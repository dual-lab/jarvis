#[cfg(target_arch = "x86_64")]
global_asm!(include_str!("x86_64/stage1.S"));
#[cfg(target_arch = "x86_64")]
global_asm!(include_str!("x86_64/check_system.S"));
#[cfg(target_arch = "x86_64")]
global_asm!(include_str!("x86_64/stage2.S"));

