#include <avrio.cc>

int main() {

    heap(vm, 0xf000);
    videomode(2);
    bank(1);

    for (int j = 0; j < 16; j++) {

        bank(1 + j);
        for (int i = 0; i < 4096; i++)
            vm[i] = i;
    }

    for(;;);
}
