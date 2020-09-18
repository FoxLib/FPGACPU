#include <avrio.cc>

// Шаблон
int main() {

    heap(vm, 0xf000);
    bank(1);

    for (int i = 0; i < 2*80*25; i += 2) { vm[i] = 'A'; vm[i+1] = 0x17; }

    // Бесконечный цикл
    for(;;);
}
