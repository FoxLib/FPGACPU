#include <avr32k/graphics.cc>

graphics D;

// Шаблон с чтением из PGM
int main() {

    D.cls(1);

    D.circlef(255, 120, 64, 0);
    D.locate(8, 8);
    D.print("Hello world!");


    // Бесконечный цикл
    for(;;);
}
