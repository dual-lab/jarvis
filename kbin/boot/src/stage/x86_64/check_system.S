.code32

.section .text
.extern _error
.global _check_system

# label: _check_system
# desc : Performe system checing for i64 arch.
# table: PHASE  | Type of check
#         1      multiboot magic check
#         2      cpuid support check
#         3      long mode support check
_check_system:
  push  ebp
  mov   ebp, esp


  call _check_system.multiboot
  call _check_system.cpuid
  call _check_system.long_mode

  leave
  ret

# label: multiboot
# desc : Performe multiboot magic number check.
_check_system.multiboot:
  push ebp
  mov ebp, esp
  
  cmp eax, 0x36d76289
  jne _check_system.multiboot.ko

  leave
  ret
# Error jmp
_check_system.multiboot.ko:
  mov al, 0x4d
  jmp _error

# label: cpuid
# desc : Performe cpuid check.
_check_system.cpuid:
  push ebp
  mov ebp, esp

  pushfd              # push FLAGS registry into the stack
  pop eax             # copy FLAGS registry into eax

  mov ecx,eax         # save old value of FLAGS registry

  xor eax, 1 << 21    # flip bit 21
  
  push eax
  popfd

  pushfd
  pop eax             # copy back the FLAGS with flipped bit if supported

  push ecx
  popfd               # restore not flipped FLAGS registry

  cmp eax, ecx
  je _check_system.cpuid.ko

  leave
  ret
# Error jmp
_check_system.cpuid.ko:
  mov al,0x43
  jmp _error

# label: long_mode
# desc : Performe long check using cpuid.
_check_system.long_mode:
  push ebp
  mov ebp, esp

  .equiv GET_HIGH_SUPPORT_ARG, 0x80000000
  .equiv GET_EXTRA_INFO, 0x80000001

  mov eax, GET_HIGH_SUPPORT_ARG   # set imput argument for cpuid
  cpuid                           # get long suported argument
  cmp eax, GET_EXTRA_INFO         # should be at least 0x80000001
  jb _check_system.long_mode.ko   # if < 0x80000001 jmp to error

  mov eax, GET_EXTRA_INFO
  cpuid                           # get extra info
  test edx, 1 << 29               # check if 29th byte is presente
  jz _check_system.long_mode.ko   # no long mode

  leave
  ret
#Error jmo
_check_system.long_mode.ko:
  mov al, 0x4c
  jmp _error
