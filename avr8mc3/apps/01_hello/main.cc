#include <avrio.cc>
#include <screen.cc>

// Шаблон с чтением из PGM
int main() {

    screen scr;

    scr.print("Hello, World!");

    for(;;);
}
