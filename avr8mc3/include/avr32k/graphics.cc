#include <screen.cc>

class graphics : public screen {
protected:
public:

    void cls(char cl) {

        DISPLAY(vm);
        for (int i = 0; i < 6144; i++)
            vm[i] = cl ? 255 : 0;

        color(cl, 1 - cl);
    }

    // Реализация рисования точки
    void pset(int x, int y, char cl) {

        DISPLAY(vm);

        if (x < 0 || y < 0 || x > 255 || y > 191) return;
        word z = ((x >> 3) | (y << 5));
        byte m = 1 << (7 ^ (x & 7));
        vm[z] = cl ? (vm[z] | m) : (vm[z] & ~m);
    }

    // Реализация рисования блока
    void block(int x1, int y1, int x2, int y2, byte cl) {
    }
};
