#include <avrio.cc>
#include <screen.cc>

// Шаблон с чтением из PGM
int main() {

    screen scr;

    //scr.print("test");
    for (int i = 0; i < 200; i++)
    for (int j = 0; j < 320; j++)
        scr.pset(j, i, i + j);

    for(;;);
}
