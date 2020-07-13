#include "ansi3.h"

class screen {
protected:

    word cursor_x, cursor_y;

public:
/*
    // Печать символа 4x8 на экране. Допустиы только 0x20 - 0x7E
    void print4(char ch) {

        if (ch < 0x20 || ch >= 0x80)
            return;

        ch -= 0x20;
        for (int i = 0; i < 8; i++) {

            char cb = ansi3[ch >> 1][i];
                 cb = ch & 1 ? cb & 15 : cb >> 4;

            for (int j = 0; j < 4; j++) {
                if (cb & (1 << (3 - j)))
                    pset(g_cursor_x + j, g_cursor_y + i, g_cursor_cl);
            }
        }

        g_cursor_x += 4;

        // Перемотка
        if (g_cursor_x >= 320) {

            g_cursor_x = 0;
            g_cursor_y++;

            // Нужна ли тут перемотка экрана?
            if (g_cursor_y >= 200) {
                g_cursor_y = 192;
            }
        }
    }
*/

    // Рисование точки на экране
    void pset(int x, int y, char cl) {

        display(vm);

        // Расчет номера байта
        word z = y*160 + (x>>1);

        cl &= 15;

        // Установка точки в ниббл
        vm[z] = x & 1 ? ((vm[z] & 0xF0) | cl) : ((vm[z] & 0x0F) | (cl << 4));
    }

    void print(const char* s) {

        display(vm);


    }
};
