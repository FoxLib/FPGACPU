#include <avr32k/graphics.cc>

graphics D;

// Шаблон с чтением из PGM
int main() {

    D.cls(1);

    D.line(0, 0, 255, 191, 0);
    D.circlef(128, 96, 16, 0);
    D.locate(8, 8);
    D.print("Hello world!");

    D.block(7, 9, 15, 9, 0);
    D.block(8, 10, 16, 10, 0);

    D.block(0, 150, 255, 191, 0);
    D.block(0, 155, 127, 160, 1);


    // Бесконечный цикл
    for(;;);
}
