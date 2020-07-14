#include <screen.cc>

screen D;

// Шаблон с чтением из PGM
int main() {

    D.cls(3);

    D.block(10, 10, 300, 150, 7);
    D.lineb(10, 10, 300, 150, 8);
    D.line (10, 10, 300, 10,  15);
    D.line (10, 10,  10, 150, 15);
    D.block(12, 12, 298, 23, 1);
    D.locate(14, 14);
    D.print("Calculator");

    // Бесконечный цикл
    for(;;);
}
