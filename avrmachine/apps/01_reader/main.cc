#include <avrio.cc>
#include <kb.cc>
#include <con.cc>

KB  kb;
CON d;

int main() {

    d.init();
    d.cls(0x07);
    d.show(0);

    d.frame(0, 0, 79, 24, 1);
    d.cursor(2, 0); d.putf8(" Чтение книг ");

    for(;;);
}
