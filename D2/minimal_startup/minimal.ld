MEMORY
{
    FLASH(rx)  : ORIGIN = 0x10000000, LENGTH = 2048k
    RAM(rwx)   : ORIGIN = 0x20000000, LENGTH = 256k
}

SECTIONS
{
    .boot2 :
    {
        KEEP(*(.boot2))
    } > FLASH

    . = ALIGN(256);
    .vectors :
    {
        KEEP(*(.vectors))
    } > FLASH
    
    .text :
    {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .bss :
    {
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        __bss_end__ = .;
    } > RAM

    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
}