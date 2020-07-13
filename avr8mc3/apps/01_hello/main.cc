#include <avrio.cc>

// Шаблон с чтением из PGM
int main() {

    disp(vm);

    for (word i = 0; i < 32000; i++)
        vm[i] = i;

    for(;;);
}
