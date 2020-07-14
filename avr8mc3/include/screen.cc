#include <avrio.cc>

#include "ansi3.h"
#include "numeric.cc"

class screen : public Numeric {
protected:

    word cursor_x, cursor_y;
    char color_fr, color_bg;

public:

    screen() {

        cursor_x = 0;
        cursor_y = 0;
        color_fr = 15;
        color_bg = -1;
    }

    void color(char fr) { color_fr = fr; }
    void color(char fr, char bg) { color_fr = fr; color_bg = bg; }
    void locate(int x, int y) { cursor_x = x; cursor_y = y; }

    // Очистить экран
    void cls(byte cl) {

        display(vm);
        cl = (cl << 4) | cl;
        for (int i = 0; i < 32000; i++)
            vm[i] = cl;
    }

    // Печать символа 4x8 на экране. Допустимы только 0x20 - 0x7E
    void print4(char ch) {

        // Возврат каретки
        if (ch == 0x0A) {

            cursor_x = 0;
            cursor_y += 8;
            return;
        }

        if (ch < 0x20 || ch >= 0x80)
            return;

        ch -= 0x20;
        word id = (ch&0x7E)<<2;
        ch &= 1;

        for (int i = 0; i < 8; i++) {

            char cb = pgm_read_byte(&ansi3[id + i]);
                 cb = ch? cb & 15 : cb >> 4;

            for (int j = 0; j < 4; j++) {

                int cx = cursor_x + j,
                    cy = cursor_y + i;

                if (cb & (1 << (3 - j)))
                    pset(cx, cy, color_fr);
                else if (color_bg >= 0)
                    pset(cx, cy, color_bg);
            }
        }

        cursor_x += 4;

        // Перемотка
        if (cursor_x >= 320) {
            cursor_x  = 0;
            cursor_y += 8;
        }
    }

    // Рисование точки на экране
    void pset(int x, int y, char cl) {

        display(vm);

        // Не должен превышать границы
        if (x < 0 || y < 0 || x >= 320 || y >= 200)
            return;

        word z = y*160 + (x>>1); // Расчет номера байта
        cl &= 15;

        // Установка точки в ниббл
        vm[z] = x & 1 ? ((vm[z] & 0xF0) | cl) : ((vm[z] & 0x0F) | (cl << 4));
    }

    // Вернуть точку
    byte point(int x, int y) {

        display(vm);
        word z = y*160 + (x>>1); // Расчет номера байта
        return x & 1 ? vm[z] & 0x0F : (vm[z] >> 4);
    }

    // Рисование линии
    void line(int x1, int y1, int x2, int y2, byte cl) {

        if (y2 < y1) {
            x1 ^= x2; x2 ^= x1; x1 ^= x2;
            y1 ^= y2; y2 ^= y1; y1 ^= y2;
        }

        int deltax = x2 > x1 ? x2 - x1 : x1 - x2;
        int deltay = y2 - y1;
        int signx  = x1 < x2 ? 1 : -1;

        int error2;
        int error = deltax - deltay;

        while (x1 != x2 || y1 != y2)
        {
            pset(x1, y1, cl);
            error2 = error * 2;

            if (error2 > -deltay) {
                error -= deltay;
                x1 += signx;
            }

            if (error2 < deltax) {
                error += deltax;
                y1 += 1;
            }
        }

        pset(x1, y1, cl);
    }

    // Ускоренное рисование блока
    void block(int x1, int y1, int x2, int y2, byte cl) {

        display(vm);

        // Выход за пределы рисования
        if (x2 < 0 || y2 < 0 || x1 >= 320 || y1 >= 200) return;
        if (x1 < 0) x1 = 0; if (x2 > 319) x2 = 319;
        if (y1 < 0) y1 = 0; if (y2 > 199) x2 = 199;

        // Расчет инициирующей точки
        word  xc = (x2>>1) - (x1>>1);     // Расстояние
        word  cc = cl | (cl << 4);        // Сдвоенный цвет
        word  z  = 160*y1 + (x1>>1), zc;

        // Коррекции, если не попадает
        if (x1 & 1) { z++; xc--; }
        if (x2 & 1) { xc++; }

        // Построение линии сверху вниз
        for (int i = y1; i <= y2; i++) {

            // Рисование горизонтальной линии
            zc = z; for (word j = 0; j < xc; j++) vm[zc++] = cc;

            // К следующему Y++
            z += 160;
        }

        // Дорисовать линии слева и справа
        if ( (x1 & 1)) for (int i = y1; i <= y2; i++) pset(x1, i, cl);
        if (!(x2 & 1)) for (int i = y1; i <= y2; i++) pset(x2, i, cl);
    }

    // Рисование окружности
    void circle(int xc, int yc, int r, byte c) {

        int x = 0;
        int y = r;
        int d = 3 - 2*y;

        while (x <= y) {

            // --
            pset(xc - x, yc + y, c);
            pset(xc + x, yc + y, c);
            pset(xc - x, yc - y, c);
            pset(xc + x, yc - y, c);
            pset(xc + y, yc + x, c);
            pset(xc - y, yc + x, c);
            pset(xc + y, yc - x, c);
            pset(xc - y, yc - x, c);
            // ...

            d += 4*x + 6;
            if (d >= 0) {
                d += 4*(1 - y);
                y--;
            }

            x++;
        }
    }

    // Закрашенная окружность
    void circlef(int xc, int yc, int r, byte c) {

        int x = 0;
        int y = r;
        int d = 3 - 2*y;

        while (x <= y) {

            block(xc-x, yc+y, xc+x, yc+y, c);
            block(xc-x, yc-y, xc+x, yc-y, c);
            block(xc-y, yc-x, xc+y, yc-x, c);
            block(xc-y, yc+x, xc+y, yc+x, c);

            d += 4*x + 6;
            if (d >= 0) {
                d += 4*(1 - y);
                y--;
            }

            x++;
        }
    }

    // Квадрат с ободком
    void lineb(int x1, int y1, int x2, int y2, byte cl) {

        line(x1, y1, x2, y1, cl);
        line(x2, y1, x2, y2, cl);
        line(x1, y2, x2, y2, cl);
        line(x1, y1, x1, y2, cl);
    }

    // Печать строки
    void print(const char* s) {

        int i = 0;
        while (byte b = s[i]) { print4(b); i++; }
    }

    // Печать целого числа
    void print(long num)  { i2a(num); print(buf); }
    void print(float num, int n) { f2a(num, n); print(buf); }

    // Рисование тайла на экране (X кратен 2), нет проверки границ
    void tile(const byte* data, int x, int y, int w, int h) {

        display(vm);

        w >>= 1;

        word z = 160*y + (x>>1), zc;
        int  n = 0;

        // Построчное рисование
        for (int i = 0; i < h; i++) {

            zc = z;
            for (int j = 0; j < w; j++) vm[zc++] = pgm_read_byte(&data[n++]);
            z += 160;
        }

    }
};
