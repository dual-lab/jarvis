.intel_syntax noprefix
.code32

.section .text
.extern _boot, _check_system
.global _start

.set VGA_BUFFER_ADDRESS, 0xb8000

# label: _start
# desc : Main entry point.
#        Performe some initial setup and check actions
_start:
  mov stack_top, esp # setup stack pointer
  mov edi, ebx       # move multiboot structure pointer to edi 
  
  call _check_system # perform system check arch dependent
  call _boot         # boot into the kernel

  hlt

# label: _error
# desc : jmp to this label if some error happen during 
#        setup process. 
# table: CODE     | Message
#         M (0x4d)  multiboot magic check error
#         C (0x43)  cpuid support error
#         L (0x4c)  no long mode support
#         P (0x50)  Paging error
#
.global _error
_error:
  mov dword ptr [VGA_BUFFER_ADDRESS], 0x4f524f45
  mov dword ptr [VGA_BUFFER_ADDRESS + 4], 0x4f3a4f52
  mov dword ptr [VGA_BUFFER_ADDRESS + 8], 0x4f204f20
  mov byte  ptr [VGA_BUFFER_ADDRESS + 10], al 

  hlt

.section .bss 
.set STACK_SIZE, 0x4000
#Stack size of 16KB  align to 16
stack_botton:
  .comm stack, STACK_SIZE, 16
stack_top:

