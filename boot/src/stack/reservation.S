.section .bss 
.intel_syntax noprefix
.code32

.set STACK_SIZE, 0x4000 
#Stack size of 16KB  align to 16
stack_botton:
  .comm stack, STACK_SIZE, 16
stack_top:

