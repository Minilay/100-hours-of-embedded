/*
 * Simplified crt0.S for RP2040, flash builds only.
 *
 * Assumptions baked in (preprocessor resolved):
 *   - PICO_RP2040 = 1
 *   - PICO_NO_FLASH = 0
 *   - PICO_MINIMAL_STORED_VECTOR_TABLE = 0
 *   - PICO_CRT0_NEAR_CALLS = 0  (safe far calls)
 *   - PICO_COPY_TO_RAM = 0
 *   - PICO_NUM_VTABLE_IRQS = 32
 *   - __ARM_ARCH_6M__ = 1  (Cortex-M0+)
 *   - PICO_CRT0_ALLOCATE_SPACERS = 1
 */

#include "pico.h"
#include "pico/asm_helper.S"
#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"

// Configure assembler for Cortex-M0+
pico_default_asm_setup

// ============================================================================
// VECTOR TABLE
// Placed at the very start of flash (0x10000100, after boot2) by linker script.
// The CPU hardware reads this table directly on reset and on every interrupt.
// ============================================================================

.section .vectors, "ax"
.align 2

.global __vectors, __VECTOR_TABLE, __vectors_end
__VECTOR_TABLE:
__vectors:

// --- System entries (ARM-defined, fixed positions) ---
.word __StackTop            // [0] initial stack pointer — loaded into SP by hardware on reset
.word _reset_handler        // [1] reset handler       — CPU jumps here on reset

// --- Exception handlers ---
.word isr_nmi               // [2]  Non-Maskable Interrupt
.word isr_hardfault         // [3]  Hard Fault
.word isr_invalid           // [4]  Reserved (MemManage — not present on M0+)
.word isr_invalid           // [5]  Reserved (BusFault  — not present on M0+)
.word isr_invalid           // [6]  Reserved (UsageFault — not present on M0+)
.word isr_invalid           // [7]  Reserved
.word isr_invalid           // [8]  Reserved
.word isr_invalid           // [9]  Reserved
.word isr_invalid           // [10] Reserved
.word isr_svcall            // [11] SVCall — software system call (used by RTOS)
.word isr_invalid           // [12] Reserved (DebugMonitor — not present on M0+)
.word isr_invalid           // [13] Reserved
.word isr_pendsv            // [14] PendSV — used by RTOS for context switching
.word isr_systick           // [15] SysTick — periodic timer tick

// --- Peripheral IRQ handlers (RP2040 has exactly 32) ---
.word isr_irq0              // TIMER_IRQ_0
.word isr_irq1              // TIMER_IRQ_1
.word isr_irq2              // TIMER_IRQ_2
.word isr_irq3              // TIMER_IRQ_3
.word isr_irq4              // PWM_IRQ_WRAP
.word isr_irq5              // USBCTRL_IRQ
.word isr_irq6              // XIP_IRQ
.word isr_irq7              // PIO0_IRQ_0
.word isr_irq8              // PIO0_IRQ_1
.word isr_irq9              // PIO1_IRQ_0
.word isr_irq10             // PIO1_IRQ_1
.word isr_irq11             // DMA_IRQ_0
.word isr_irq12             // DMA_IRQ_1
.word isr_irq13             // IO_IRQ_BANK0
.word isr_irq14             // IO_IRQ_QSPI
.word isr_irq15             // SIO_IRQ_PROC0
.word isr_irq16             // SIO_IRQ_PROC1
.word isr_irq17             // CLOCKS_IRQ
.word isr_irq18             // SPI0_IRQ
.word isr_irq19             // SPI1_IRQ
.word isr_irq20             // UART0_IRQ
.word isr_irq21             // UART1_IRQ
.word isr_irq22             // ADC_IRQ_FIFO
.word isr_irq23             // I2C0_IRQ
.word isr_irq24             // I2C1_IRQ
.word isr_irq25             // RTC_IRQ
.word isr_irq26             // unused
.word isr_irq27             // unused
.word isr_irq28             // unused
.word isr_irq29             // unused
.word isr_irq30             // unused
.word isr_irq31             // unused

__vectors_end:

// ============================================================================
// DEFAULT ISR HANDLERS
//
// All labels below share the same address — they emit no instructions.
// They all fall through to __unhandled_user_irq which captures which IRQ
// fired into r0 before hitting bkpt #0.
//
// Each label is weak — override any of them from C by defining a function
// with the same name, e.g.:  void isr_irq20(void) { ... }  for UART0.
// ============================================================================

.global __default_isrs_start
__default_isrs_start:

// Macro: empty weak label — no body, falls through to __unhandled_user_irq
.macro decl_isr name
.weak \name
.type \name,%function
.thumb_func
\name:
.endm

// Macro: weak label with its own bkpt — for named system exceptions
.macro decl_isr_bkpt name
.weak \name
.type \name,%function
.thumb_func
\name:
    bkpt #0
.endm

// --- 32 peripheral IRQ default handlers (all empty, all same address) ---
decl_isr isr_irq0
decl_isr isr_irq1
decl_isr isr_irq2
decl_isr isr_irq3
decl_isr isr_irq4
decl_isr isr_irq5
decl_isr isr_irq6
decl_isr isr_irq7
decl_isr isr_irq8
decl_isr isr_irq9
decl_isr isr_irq10
decl_isr isr_irq11
decl_isr isr_irq12
decl_isr isr_irq13
decl_isr isr_irq14
decl_isr isr_irq15
decl_isr isr_irq16
decl_isr isr_irq17
decl_isr isr_irq18
decl_isr isr_irq19
decl_isr isr_irq20
decl_isr isr_irq21
decl_isr isr_irq22
decl_isr isr_irq23
decl_isr isr_irq24
decl_isr isr_irq25
decl_isr isr_irq26
decl_isr isr_irq27
decl_isr isr_irq28
decl_isr isr_irq29
decl_isr isr_irq30
decl_isr isr_irq31

// All unhandled peripheral IRQs fall through to here (same address as above).
// Reads IPSR to find which IRQ fired, subtracts 16 to get IRQ number into r0,
// then halts the debugger. r0 tells you exactly which IRQ was unhandled.
.global __unhandled_user_irq
.thumb_func
__unhandled_user_irq:
    mrs  r0, ipsr       // r0 = current exception number from CPU status register
    subs r0, #16        // convert to IRQ number (IRQ0 = exception 16)
.global unhandled_user_irq_num_in_r0
unhandled_user_irq_num_in_r0:
    bkpt #0             // halt debugger — inspect r0 to see which IRQ fired

// Individual named breakpoints for system exceptions.
// Each has its own bkpt so debugger shows the exception name directly.
decl_isr_bkpt isr_invalid   // catch-all for reserved slots
decl_isr_bkpt isr_nmi
decl_isr_bkpt isr_hardfault
decl_isr_bkpt isr_svcall
decl_isr_bkpt isr_pendsv
decl_isr_bkpt isr_systick

.global __default_isrs_end
__default_isrs_end:

// ============================================================================
// RESET SECTION
// Contains the ELF entry point (_entry_point) and the real reset handler
// (_reset_handler). The CPU jumps to _reset_handler via the vector table.
// _entry_point is only used by the debugger.
// ============================================================================

.section .reset, "ax"

// ----------------------------------------------------------------------------
// _entry_point — debugger entry point (not used on normal hardware boot)
//
// When GDB loads the .elf, it reads the ELF entry point field and jumps here.
// On a flash build, flash may not be initialized (boot2 was skipped), so
// we send execution back through the bootrom which will run boot2 properly.
// ----------------------------------------------------------------------------

.type _entry_point,%function
.thumb_func
.global _entry_point
_entry_point:
    // Flash not initialized by debugger — go back through bootrom + boot2
    ldr r0, =BOOTROM_VTABLE_OFFSET

// Both _entry_point and _reset_handler join here.
// r0 = address of vector table to use (ours or bootrom's)
_enter_vtable_in_r0:
    ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)  // address of VTOR register
    str r0, [r1]                               // VTOR = our vector table
    ldmia r0!, {r1, r2}                        // r1 = __StackTop, r2 = _reset_handler
    msr msp, r1                                // SP = __StackTop
    bx r2                                      // jump to _reset_handler

// ----------------------------------------------------------------------------
// _reset_handler — real entry point on hardware reset
//
// Reached via vector table slot 1 on power-on.
// Performs full C runtime initialization then calls main().
// ----------------------------------------------------------------------------

.type _reset_handler,%function
.thumb_func
_reset_handler:

    // --- Core check ---
    // Only core 0 should run C runtime init.
    // Core 1 is normally sleeping in bootrom — send it back if it ended up here.
    ldr r0, =(SIO_BASE + SIO_CPUID_OFFSET)  // address of CPUID register
    ldr r0, [r0]                             // r0 = 0 (core 0) or 1 (core 1)
    cmp r0, #0
    beq 1f                                   // core 0 — continue with init

hold_non_core0_in_bootrom:
    ldr r0, =BOOTROM_VTABLE_OFFSET           // core 1 — send back to bootrom
    b _enter_vtable_in_r0
1:

    // --- Copy .data from flash to RAM ---
    // data_cpy_table lists all flash→RAM regions to copy.
    // Each entry is a triplet: { source, dest_start, dest_end }
    // A zero source address terminates the table.
    adr r4, data_cpy_table
1:
    ldmia r4!, {r1-r3}  // r1=source, r2=dest_start, r3=dest_end
    cmp r1, #0          // null terminator?
    beq 2f              // yes — done copying
    bl data_cpy         // no  — copy this region
    b 1b
2:

    // --- Zero out .bss ---
    // All uninitialized globals must be zero when main() starts (C standard).
    ldr r1, =__bss_start__
    ldr r2, =__bss_end__
    movs r0, #0
    b bss_fill_test
bss_fill_loop:
    stm r1!, {r0}       // write 4 zero bytes, advance r1
bss_fill_test:
    cmp r1, r2
    bne bss_fill_loop   // loop until r1 reaches r2

    // --- Call C runtime, then your code ---
platform_entry:         // named for clean stack traces in debugger
    ldr r1, =runtime_init
    blx r1              // initialize clocks, peripherals, pre-inits
    ldr r1, =main
    blx r1              // YOUR CODE runs here
    ldr r1, =exit
    blx r1              // called if main() returns (it shouldn't)

    // exit should never return. If it does — hang safely.
1:
    bkpt #0
    b 1b

// ----------------------------------------------------------------------------
// data_cpy — copy r3-r2 bytes from r1 to r2
//
// Arguments:
//   r1 = source start (flash)
//   r2 = destination start (RAM)
//   r3 = destination end (RAM)
//
// Entry at data_cpy: checks condition first (while loop).
// Loop body at data_cpy_loop: copies 4 bytes per iteration.
// ----------------------------------------------------------------------------

data_cpy_loop:
    ldm r1!, {r0}   // load 4 bytes from source, r1 += 4
    stm r2!, {r0}   // store 4 bytes to dest,   r2 += 4
data_cpy:
    cmp r2, r3      // reached end?
    blo data_cpy_loop   // no — copy more
    bx lr               // yes — return

// ----------------------------------------------------------------------------
// data_cpy_table — describes every flash→RAM copy needed at startup
//
// Format: triplets of { source_in_flash, dest_start_in_RAM, dest_end_in_RAM }
// All __ symbols defined by the linker script (memmap_default.ld).
// ----------------------------------------------------------------------------

.p2align 2
data_cpy_table:
.word __etext           // initialized globals: source in flash (after code)
.word __data_start__    //                      destination start in RAM
.word __data_end__      //                      destination end in RAM

.word __scratch_x_source__  // scratch X bank initial values
.word __scratch_x_start__
.word __scratch_x_end__

.word __scratch_y_source__  // scratch Y bank initial values
.word __scratch_y_start__
.word __scratch_y_end__

.word 0                 // null terminator — end of table

// ----------------------------------------------------------------------------
// Weak default for runtime_init.
// Real implementation in platform.c sets up clocks, stdio, etc.
// This fallback exists so the binary links even without platform.c.
// ----------------------------------------------------------------------------

.weak runtime_init
.type runtime_init,%function
.thumb_func
runtime_init:
    bx lr   // do nothing — return immediately

// ============================================================================
// STACK AND HEAP SIZE RESERVATIONS
// These sections contain no meaningful data — just space reserved in RAM
// so the linker can verify everything fits and include sizes in memory reports.
// ============================================================================

.section .stack, "a"
.p2align 5                          // 32-byte alignment for MPU compatibility
.equ StackSize, PICO_STACK_SIZE     // default: 0x800 = 2048 bytes
.if StackSize != 0
.space StackSize
.endif

.section .heap, "a"
.p2align 2                          // 4-byte alignment
.equ HeapSize, PICO_HEAP_SIZE       // default: 0x800 = 2048 bytes
.if HeapSize != 0
.space HeapSize
.endif