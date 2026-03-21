#include <stdio.h>
#include <ctype.h>
#include "readchar.h"
#include "getfloat.h"

int getfloat(float *pn)
{
    int c, sign;
    while (isspace(c = getch()));

    if (!isdigit(c) && c != EOF && c != '+' && c != '-' && c != '.') {
        ungetch(c); /* it is not a number */
        return 0;
    }
    sign = (c == '-') ? -1 : 1;
    if (c == '+' || c == '-')
    {
        int sign_char = c;
        c = getch();
        if (!isdigit(c) && c != '.')
        {
            ungetch(c);
            ungetch(sign_char);
            return 0;
        }
    }

    int whole = 0;
    for (whole = 0; isdigit(c); c = getch())
        whole = 10 * whole + (c - '0');
    
    // printf("whole %d\n", whole);
    float part = 0;
    int divider = 1;
    if (c == '.'){
        c = getch();
        for (part = 0; isdigit(c); c = getch()){
            part = 10 * part + (c-'0');
            divider *= 10;
        }
    }
    part = part / divider;
    *pn = sign * (whole+part);
    // printf("Result: %f", *pn);
    if (c != EOF)
        ungetch(c);
    return c;
}
