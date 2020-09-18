#include <avrio.cc>

void pset(word x, word y, byte cl) {

    heap(vm, 0xf000);
    word t = y*320 + x;
    bank((t >> 12) + 1);
    vm[t & 0x0FFF] = cl;
}

int main() {

    videomode(2);

    for (word y = 0; y < 200; y++)
    for (word x = 0; x < 320; x++) {
        pset(x, y, x);
    };

    for(;;);
}
