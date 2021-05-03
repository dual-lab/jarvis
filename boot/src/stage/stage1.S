.intel_syntax noprefix
.code32

.section .text
.extern _boot
.global _start

_start:
  mov stack_top, esp
  call _boot

  hlt

.section .bss 
.set STACK_SIZE, 0x4000 
#Stack size of 16KB  align to 16
stack_botton:
  .comm stack, STACK_SIZE, 16
stack_top:

