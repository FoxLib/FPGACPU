#include <avrio.cc>

int main() {

    heap(vm, 0xf000);

    for (int i = 0; i < 4000; i++)
        vm[i] = i;

    for(;;);
}
