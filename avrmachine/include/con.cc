#include <avrio.cc>
#include <numeric.cc>
#include <con.h>

class CON : public numeric {
protected:

    byte cursor_x, cursor_y, cursor_cl, cursor_show;

public:

    void init() {

        outp(BANK_LO,   0);
        outp(BANK_HI,   0);
        outp(VIDEOMODE, VM_80x25);

        cursor(0, 0);
        show(1);
    }

    // Установка текстового курсора в нужную позицию
    void cursor(byte x, byte y) {

        cursor_x = x;
        cursor_y = y;

        if (cursor_show) {

            outp(CURSOR_X, x);
            outp(CURSOR_Y, y);
        }
    }

    // Цвет новых символов
    void color(byte cl) { cursor_cl = cl; }

    // Показать/скрыть курсор
    void show(byte visible) {

        cursor_show = visible;
        cursor(cursor_x, visible ? cursor_y : 25);
    }

    // Очистка экрана
    void cls(byte cl) {

        heap(vm, 0xF000);

        for (int i = 0; i < 4000; i += 2) {
            vm[i+0] = 0;
            vm[i+1] = cl;
        }

        cursor(0, 0);
        cursor_cl = cl;
    }

    // Печать символа на экране
    void prn(byte x, byte y, char ch) {

        heap(vm, 0xF000);
        int   z = (x<<1) + (y<<7) + (y<<5);

        vm[z]   = ch;
        vm[z+1] = cursor_cl;
    }

    // Печать в режиме телетайпа
    void printb(byte s) {

        int i;
        heap(vm, 0xF000);

        if (s == 10) {
            cursor_x = 80;
        } else {
            prn(cursor_x, cursor_y, s);
            cursor_x++;
        }

        if (cursor_x >= 80) {
            cursor_x = 0;
            cursor_y++;
        }

        // Скроллинг навверх
        if (cursor_y >= 25) {

            for (i = 0; i < 4000 - 160; i += 2) {
                vm[i]   = vm[i + 160];
                vm[i+1] = vm[i + 161];
            }

            // Очистка новой строки
            for (i = 4000 - 160; i < 4000; i += 2) {
                vm[i]   = ' ';
                vm[i+1] = cursor_cl;
            }

            cursor_y = 24;
        }

        cursor(cursor_x, cursor_y);
    }

    // Печать строки
    int print(const char* s) {

        int i = 0;
        while (s[i]) { printb(s[i++]); }
        return i;
    }

    // Печать строки, форматированной в UTF8
    int putf8(const char* s) {

        int i = 0, n = 0;
        while (s[i]) {

            byte ch = s[i++];

            if (ch == 0xD0) { // Главный набор

                ch = s[i++];
                ch = (ch == 0x81 ? 0xF0 : ch - 0x10);

            } else if (ch == 0xD1) { // Вторичный набор

                ch = s[i++];
                ch = (ch == 0x91 ? 0xF1 : ch + (ch < 0xB0 ? 0x60 : 0x10));
            }

            printb(ch);
            n++;
        }

        return n;
    }

    // Печать чисел
    int print(long num)         { i2a(num); return print(buf); }
    int print(float num, int n) { f2a(num, n); return print(buf); }
};
