#include "ansi3.h"

class screen {
protected:

    word cursor_x, cursor_y;
    byte color_fr;

public:

    screen() {

        cursor_x = 0;
        cursor_y = 0;
        color_fr = 15;
    }

    // Печать символа 4x8 на экране. Допустиы только 0x20 - 0x7E
    void print4(char ch) {

        if (ch < 0x20 || ch >= 0x80)
            return;

        ch -= 0x20;
        word id = (ch&0x7E)<<2;
        ch &= 1;

        for (int i = 0; i < 8; i++) {

            char cb = pgm_read_byte(&ansi3[id + i]);
                 cb = ch? cb & 15 : cb >> 4;

            for (int j = 0; j < 4; j++) {
                if (cb & (1 << (3 - j)))
                    pset(cursor_x + j, cursor_y + i, color_fr);
            }
        }

        cursor_x += 4;

        // Перемотка
        if (cursor_x >= 320) {

            cursor_x = 0;
            cursor_y += 8;

            if (cursor_y >= 200) {
                cursor_y = 192;
            }
        }
    }

    // Рисование точки на экране
    void pset(int x, int y, char cl) {

        display(vm);

        // Расчет номера байта
        word z = y*160 + (x>>1);

        cl &= 15;

        // Установка точки в ниббл
        vm[z] = x & 1 ? ((vm[z] & 0xF0) | cl) : ((vm[z] & 0x0F) | (cl << 4));
    }

    // Печать строки
    void print(const char* s) {

        int i = 0;

        while (byte b = s[i]) {
            print4(b); i++;
        }
    }
};
