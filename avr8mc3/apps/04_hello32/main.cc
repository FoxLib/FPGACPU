#include <avr32k/graphics.cc>

graphics D;

// Шаблон с чтением из PGM
int main() {

    D.cls(1);
    D.line(0, 0, 255, 191, 0);
    D.circle(128, 96, 16, 0);
    D.locate(8, 8);
    D.print("Hello world!");

    // Бесконечный цикл
    for(;;);
}
