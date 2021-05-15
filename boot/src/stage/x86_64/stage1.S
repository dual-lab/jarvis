.intel_syntax noprefix
.code32

.section .text
.extern _check_system, _stage2
.global _start

.set VGA_BUFFER_ADDRESS, 0xb8000

# label: _start
# desc : Main entry point.
#        Performe some initial setup and check actions
_start:
  mov esp, offset stack_top     # setup stack pointer
  mov edi, ebx                  # move multiboot structure pointer to edi 
  
  call _check_system            # perform system check arch dependent
  jmp _stage2                   # jmp to stage2 initialization

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
# reserve space for page mepping table
# aligned to 4096B
.set PAGE_TABLE_SIZE, 0x1000
.balign PAGE_TABLE_SIZE
_pml4:
  .lcomm p4, PAGE_TABLE_SIZE
_pdp:
  .lcomm p3, PAGE_TABLE_SIZE
_pd:
  .lcomm p2, PAGE_TABLE_SIZE
#Stack size of 16KB  align to 16
.equiv STACK_SIZE, 0x4000
.balign 16
stack_botton:
  .lcomm stack, STACK_SIZE
stack_top:

