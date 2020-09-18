#include <avrio.cc>

class screen3 {
protected:
public:

    screen3(byte cl) { start(); cls(cl); }

    void start() { videomode(0); }

    // Очистить экран в определенный цвет
    void cls(byte cl) {

        bank(1);
        heap(vm, 0xf000);

        for (int i = 0; i < 4000; i += 2) {

            vm[i+0] = ' ';
            vm[i+1] = cl;
        }
    }
};
