#include <screen.cc>

class graphics : public screen {
protected:
public:

    // Реализация рисования точки
    void pset(int x, int y, char cl) {
    }

    // Реализация рисования блока
    void block(int x1, int y1, int x2, int y2, byte cl) {
    }
};
