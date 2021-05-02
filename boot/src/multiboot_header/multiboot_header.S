.section .multiboot_header, "a", @progbits
.intel_syntax noprefix
.code32

.set MULTIBOOT_MAGIC, 0xe85250d6

.align 8                            # multiboot header aling
header_start:
    .long MULTIBOOT_MAGIC           # magic number (multiboot 2)
    .long 0                         # architecture 0 (protected mode i386)
    .long header_end - header_start # header length
    .long -(MULTIBOOT_MAGIC + 0 + (header_end - header_start)) # checksum

    # insert optional multiboot tags here

    # required end tag
    .short 0    # type
    .short 0    # flags
    .long  8    # size
header_end:
