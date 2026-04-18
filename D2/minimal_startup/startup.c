#include <stdint.h>

// 1. Declare your reset handler first so you can reference it
void reset_handler(void);

void default_handler(void) {
    while(1);  // hang — makes unhandled IRQs visible
}
// 2. The vector table — placed in a special section by the linker
// Index 0 = initial stack pointer (provided by linker as __StackTop)
// Index 1 = reset handler address
extern uint32_t __StackTop;  // linker provides this symbol

__attribute__((section(".vectors")))
void (*vector_table[])(void) = {
    
    (void (*)(void))&__StackTop,  // entry 0: initial stack pointer
    reset_handler,                 // entry 1: reset handler
    default_handler,               // entry 2: NMI
    default_handler,               // entry 3: HardFault
    0, 0, 0, 0, 0, 0, 0,          // entries 4-10: reserved
    default_handler,               // entry 11: SVCall
    0, 0,                          // entries 12-13: reserved
    default_handler,               // entry 14: PendSV
    default_handler,               // entry 15: SysTick

};

extern uint32_t __bss_start__;
extern uint32_t __bss_end__;
extern int main();
// 3. The reset handler — this is what the CPU jumps to on boot
void reset_handler(void) {
    // zero .bss here
    // then call main()
    for(volatile uint32_t *i = &__bss_start__; i < &__bss_end__; i++) {
        *i = 0;
    }
    main();
}
