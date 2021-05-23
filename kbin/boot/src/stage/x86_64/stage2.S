.intel_syntax noprefix
.code32

.section .text
.global _stage2
.extern _boot

_stage2:

  call _init_page_table
  call _enable_paging
  
  lgdt gt_64.pointer    # load 64-bit descriptor table

  # reload code selector with a far return
  push offset gt_64.code_offset
  mov eax, offset _boot
  push eax
  retf

  hlt

# label: _init_page_table
# desc : Initialize page table structure with huge page on PD table
_init_page_table:
  push ebp
  mov ebp, esp
  
  xor eax, eax

  # map first entry of pml4 to pdp
  mov eax,offset _pdp
  or eax, 0b11                  # set writable + present flags
  mov [_pml4], eax
  # map first entry of pdp to pd
  mov eax, offset _pd
  or eax, 0b11                  # set writable + present flags
  mov [_pdp], eax
  # map p2 huge page table to 2Mib page
  xor ecx, ecx
  mov eax, 0b10000011           # set huge page + writable + present flags
  .map_pd_table_loop:
    mov [_pd + ecx*8], eax      # set 2Mib of address into PD table
    add eax, 0x200000           # increment address by 2Mib
    inc ecx                     # increment counter
    cmp ecx, 512                # compare with table len
    jb .map_pd_table_loop        # jmp to loop if counter < 512

  leave
  ret

# label: _enable_paging
# desc : Enable paging into cr3,cr0 register + enable PAE into cr4 + set long mode
#        into  EFER MSR register
_enable_paging:
  push ebp
  mov ebp,esp
  
  mov eax, offset _pml4     # load pml4 address 
  mov cr3, eax              # load pml4 address into cr3 cpu register

  # enable PAE-flag into cr4 (Physical Address Exstension)
  mov eax, cr4
  or eax, 1 << 5
  mov cr4, eax

  # set long mode into EFER MSR register
  mov ecx, 0xC0000080
  rdmsr
  or eax, 1 << 8
  wrmsr

  # enable paging into the cr0 register
  mov eax, cr0
  or eax, 1 << 31
  mov cr0, eax

  leave
  ret

  .section .rodata
  .balign 4
  gt_64:
    .quad 0x0000000000000000          # null descriptor
  .equiv gt_64.code_offset, . - gt_64 # store code offset
    .quad 0x00209A0000000000          # 64-bit code segment (rx)
    .quad 0x0000920000000000          # 64-bit data segment (rw)

  gt_64.pointer:
    .word . - gt_64 -1
    .long gt_64
