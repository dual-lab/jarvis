ENTRY(_start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* ensure that the multiboot header is at the beginning */
        KEEP(*(.multiboot_header))
    }

    .text :
    {
        *(.text .text.*)
    }

    .bss :
    {
         *(.bss .bss.*)
    }

    .data :
    {
          *(.data .data.*)
    }

    .rodata :
    {
          *(.rodata .rodata.*)
    }
}
