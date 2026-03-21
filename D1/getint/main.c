#include <stdio.h>
#include "getfloat.h"

int main(void)
{
    int n;
    float array[100];

    for (n = 0; n < 100 && getfloat(&array[n]) != EOF; n++)
        ;

    for (int i = 0; i < n; i++)
    {
        printf("a[%d] = %f\n", i, array[i]);
    }
    return 0;
}