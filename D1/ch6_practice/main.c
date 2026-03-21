#include <stdio.h>
#include <stdint.h>

struct Reg_bits {
    uint32_t :8;
    uint32_t OUTFROMPERI :1;
    uint32_t OUTTOPAD : 1;
    uint32_t :2;
    uint32_t OEFROMPERI :1;
    uint32_t OETOPAD: 1;
    uint32_t :3;
    uint32_t INFROMPAD :1;
    uint32_t : 1;
    uint32_t INTOPERI :1;
    uint32_t :4;
    uint32_t IRQFROMPAD :1;
    uint32_t :1;
    uint32_t IRQTOPROC : 1;
    uint32_t : 5;
};

typedef union  {
    uint32_t raw;
    struct Reg_bits bits;
} GPIO_status_reg;

int main()
{
    GPIO_status_reg sr;
    sr.raw = 0;
    sr.bits.INFROMPAD = 1;
    sr.bits.IRQTOPROC = 1;
    printf("Hex result: 0x%x\n", sr.raw);

    sr.raw = 0x04020200;
    struct Reg_bits b = sr.bits;
    printf("%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n",
        b.INFROMPAD,
        b.INTOPERI,
        b.IRQFROMPAD,
        b.IRQTOPROC,
        b.OEFROMPERI,
        b.OETOPAD,
        b.OUTFROMPERI,
        b.OUTTOPAD
    );
}
