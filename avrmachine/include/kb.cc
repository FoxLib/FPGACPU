#include <avrio.cc>
#include "kb.h"

class KB {

protected:

    byte _shift, _spec, _ctrl;

public:

    KB() {

        _shift = 0;
        _ctrl  = 0;
        _spec  = 0;
    }

    inline byte hit() { return inp(KB_HIT) & 1; }
    inline byte key() { return inp(KB_DATA); }

    // Чтение из порта нового символа
    byte inkey() {

        byte ascii = 0;

        // Ожидание нажатия клавиши
        if (hit()) {

            ascii = key();

            // Кнопку отпускания не использовать
            if ((ascii & 0x80)) ascii = 0;
        }

        return ascii;
    }

    // Ожидание получения нажатия клавиши
    byte getch() { byte k; while ((k = inkey()) == 0); return k; }
};
