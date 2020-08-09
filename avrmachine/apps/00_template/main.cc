#include <avrio.cc>
#include <kb.cc>

KB kb;

int main() {

    heap(vm, 0xf000);

    int i = 0;
    for(;;) {

        int k = kb.getch();

        vm[i++] = k;
        vm[i++] = 0x17;
    }
}
