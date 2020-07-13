#include <avrio.cc>
#include <screen.cc>

// Шаблон с чтением из PGM
int main() {

    screen D;

    D.line(0, 0, 320, 199, 11);
    D.circle(160, 100, 50, 10);

    D.color(15, 1);
    D.locate(8, 8);
    D.print("Hello, World!");

    for(;;);
}
