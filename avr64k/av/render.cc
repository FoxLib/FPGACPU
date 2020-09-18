#include "main.h"

// Обновить весь экран
void APP::display_update() {

    cls(0);

    switch (videom) {

        // Видеорежим 80x30
        case 0: break;

        // Видеорежим 640x480x4
        case 1: for (int i = 0; i < 150*1024; i++) update_byte_scr(0x10000 + i); break;
    }
}

// Видеопамять начинается с $10000 (1-я страница)
void APP::update_byte_scr(int addr) {

    // Не рендерить в дебаггере
    if (ds_debugger) return;

    int x, y;
    addr -= 0x10000;

    switch (videom) {

        case 0: // TEXT 80x25x16

            x = (addr>>1) % 80;
            y = (addr>>1) / 80;
            if (addr < 4000) update_text_xy(x, y);
            break;

        case 1: // GRAPHICS 640x480x4

            break;
    }
}

// Обновить текст в (X, Y)
void APP::update_text_xy(int X, int Y) {

    int k;
    int addr = 0x10000 + 2*(X + Y*80);
    int ch   = sram[ addr + 0 ];
    int attr = sram[ addr + 1 ];

    for (int y = 0; y < 16; y++) {

        // int ft = sram[0x10000 + 16*ch + y];
        int ft = ansi16[ch][y];
        for (int x = 0; x < 8; x++) {

            int cbit   = ft & (1 << (7 - x));
            int cursor = (cursor_x == X && cursor_y == Y) && (y >= 14) ? 1 : 0;
            int color  = cbit ^ (flash & cursor) ? (attr & 0x0F) : (attr >> 4);

            // Вычисляется цвет из заданной палитры
            // int gb = sram[0xFFA0 + 2*color];
            // int  r = sram[0xFFA1 + 2*color];
            // color = ((gb & 0x0F) << 4) | ((gb & 0xF0) << 8) | ((r & 0x0F) << 20);
            color = DOS_13[color];

            // 2x2 Размер пикселя
            for (int k = 0; k < 4; k++) pset(2*(8*X + x) + k%2, 2*(16*Y + y) + k/2, color);
        }
    }

    text_px = X;
    text_py = Y;
}

