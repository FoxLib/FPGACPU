#include <avr32k/graphics.cc>

graphics D;

// Шаблон с чтением из PGM
int main() {

    D.cls(0);

    D.circlef(255, 120, 64, 1);
    D.locate(8, 8);
    D.print("Hello world! This 256x192 pix, 6kb. 32kb FLASH ROM. 8kb RAM");


    // Бесконечный цикл
    for(;;);
}
