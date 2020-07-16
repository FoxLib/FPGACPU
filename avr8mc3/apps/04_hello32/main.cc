#include <avr32k/graphics.cc>

graphics D;

int main() {

    D.cls(0);

    D.circlef(255, 120, 128, 1);
    D.locate(8, 8);
    D.print("Hello world! This 256x192 pix, 6kb. 32kb FLASH ROM. 8kb RAM");

    D.block(10, 30, 160, 100, 1);
    D.block(11, 31, 159, 39, 0);
    D.locate(12, 32); D.print("Windows XP");
    D.color(0, 1);
    D.locate(12, 42); D.print("Yeto cherno-beloe izobrazhenie desu");
    D.lineb(9, 29, 161, 101, 0);

    // Бесконечный цикл
    for(;;);
}
