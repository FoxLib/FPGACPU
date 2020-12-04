#include <math.h>

unsigned long __udivmodsi4(unsigned long num, unsigned long den, int modwanted) {

    unsigned long bit = 1;
    unsigned long res = 0;

    while (den < num && bit && !(den & (1L<<31))) {

        den <<= 1;
        bit <<= 1;
    }

    while (bit) {

        if (num >= den) {
            num -= den;
            res |= bit;
        }

        bit >>=1;
        den >>=1;
    }

    return (modwanted) ? num : res;
}

/*
 * 32-bit signed integer divide.
 */
signed int __aeabi_idiv(signed int num, signed int den)
{
    signed int minus = 0;
    signed int v;

    if (num < 0){
        num = -num;
        minus = 1;
    }

    if (den < 0){
        den = -den;
        minus ^= 1;
    }

    v = __udivmodsi4(num, den, 0);
    if (minus)
        v = -v;

    return v;
}

void output(int a, int b) {

    char* m = (char*) 0x100000;
    for (int i = a; i < b; i++)
        m[i] = i / a;
}

int main() {



    output(0, 50);
    output(20, 40);

    return 0;
}
