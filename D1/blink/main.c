#include <stdint.h>

#define IO_BANK0_BASE   0x40014000U
#define GPIO25_CTRL     0x0ccU
#define GPIO0_CTRL      0x004U
#define SIO_BASE        0xD0000000U
#define GPIO_OUT        0xD0000010U
#define GPIO_OUT_XOR    0xD000001CU //TODO: Toggle LED using this register

#define GPIO_OE         0xD0000020U
#define RESETS_BASE     0x4000C000U
#define RESETS_DONE_OFFSET     0x8U

#define GPIO_BIT (1U << 0)
// IO_BANK0:       bit 5
// PADS_BANK0:     bit 8
int main()
{
    // volatile uint32_t *RESET = (volatile uint32_t *) RESETS_BASE;
    // *RESET &= ~((1U<<5) | (1U << 8));

    // volatile uint32_t *RESET_DONE = (volatile uint32_t *) (RESETS_BASE + RESETS_DONE_OFFSET);
    // while ((*RESET_DONE & ((1U << 5) | (1U << 8))) != ((1U << 5) | (1U << 8)));

    volatile uint32_t *GPIO_CTRL = (volatile uint32_t *) (GPIO0_CTRL + IO_BANK0_BASE);
    *GPIO_CTRL &= ~(0x1FU);  // clear bits 4:0
    *GPIO_CTRL |= 0x5U;       // set function 5 (SIO)

    volatile uint32_t *gpio_oe = (volatile uint32_t *) GPIO_OE;
    *gpio_oe |= GPIO_BIT;

    volatile uint32_t *gpio_out = (volatile uint32_t *) GPIO_OUT;
    *gpio_out |= GPIO_BIT; // Not trying to blink. Just trying to turn it on for now.

    while (1) {
        *gpio_out |= GPIO_BIT;
        for (volatile int i = 0; i < 500000; i++);  // busy wait
    
        *gpio_out &= ~GPIO_BIT;
        for (volatile int i = 0; i < 500000; i++);
    }
}