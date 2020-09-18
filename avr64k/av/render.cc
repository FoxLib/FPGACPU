#include "main.h"

// Обновить весь экран
void APP::display_update() {

    cls(0);

    // Видеорежим 320x200x4 или 256x192x1
    for (int i = 0; i < (cpu_model == ATTINY85 ? 32000 : 6144); i++)
        update_byte_scr(0x8000 + i);

}

// 0x8000 - 0xFFFF Видеопамять
void APP::update_byte_scr(int addr) {

    int xshift = (width  - 640) / 2,
        yshift = (height - 400) / 2;

    // Область видеопамяти
    if (!ds_debugger) {

        addr -= 0x8000;

        // 320x200x4 для Attiny85
        if (cpu_model == ATTINY85) {

            if (addr >= 0 && addr < 32000) {

                int  X = (addr % 160) << 1;
                int  Y = (addr / 160);
                int  cb = sram[0x8000 + addr];

                // 2 Пикселя в байте
                for (int o = 0; o < 2; o++) {

                    uint cl = o ? cb & 15 : (cb >> 4);
                         cl = DOS_13[cl];

                    if (height <= 480) {
                        for (int m = 0; m < 4; m++) {
                            pset((X + o)*2 + (m>>1) + xshift, Y*2 + (m&1) + yshift , cl);
                        }
                    } else {
                        for (int m = 0; m < 16; m++) {
                            pset(4*(X + o) + (m>>2), 4*Y + (m&3), cl);
                        }
                    }
                }
            }
        }
        // Просто модель памяти такая
        else if (cpu_model == ATMEGA328) {

            int s = (width >= 1024 && height >= 800) ? 4 : 2;

            xshift = (width  - s*256) / 2,
            yshift = (height - s*192) / 2;

            if (addr >= 0 && addr < 6144) {

                int  X = (addr & 0x1F);
                int  Y = (addr >> 5);
                int  cb = sram[0x8000 + addr];

                for (int i = 0; i < 8; i++) {

                    int cl = cb & (1 << (7-i)) ? DOS_13[7] : 0;

                    for (int m = 0; m < s*s; m++)
                    pset(xshift + (8*X+i)*s + (m%s), yshift + Y*s + (m/s), cl);
                }
            }
        }
    }
}
