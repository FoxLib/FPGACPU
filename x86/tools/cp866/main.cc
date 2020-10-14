#include "screen.cc"

static const char* display[25] = {

//             1         2         3         4         5         6         7
//   01234567890123456789012345678901234567890123456789012345678901234567890123456789
    "> Welcome to National Electronix Stepping Family                                ", /*  0 */
    "| Intel Inside                                                                  ", /*  1 */
    "| Idiot Outside                                                                 ", /*  2 */
    "                                                                                ", /*  3 */
    "                                                                                ", /*  4 */
    "                                                                                ", /*  5 */
    "                                                                                ", /*  6 */
    "                                                                                ", /*  7 */
    "                                                                                ", /*  8 */
    "                                                                                ", /*  9 */
    "                                                                                ", /* 10 */
    "                                                                                ", /* 11 */
    "                                                                                ", /* 12 */
    "                                                                                ", /* 13 */
    "                                                                                ", /* 14 */
    "                                                                                ", /* 15 */
    "                                                                                ", /* 16 */
    "                                                                                ", /* 17 */
    "                                                                                ", /* 18 */
    "                                                                                ", /* 19 */
    "                                                                                ", /* 20 */
    "                                                                                ", /* 21 */
    "                                                                                ", /* 22 */
    "                                                                                ", /* 23 */
    "                                                                               +", /* 24 */
};

int main(int argc, char** argv) {

    screen app(1280, 800);

    uint8_t fnt[4096];
    FILE* fp = fopen("font.fnt", "rb");
    fread(fnt, 1, 4096, fp);
    fclose(fp);

    int px, py;

    // Показать текст 80x25
    for (py = 0; py < 25; py++)
    for (px = 0; px < 80; px++) {

        int ch = display[py][px];
        for (int y = 0; y < 16; y++)
        for (int x = 0; x < 8; x++)
            for (int k = 0; k < 4; k++)
                app.pset(16*px + 2*x + (k/2), 32*py + 2*y + (k&1), fnt[ch*16 + y] & (1 << (7-x)) ? 0xffffff : 0);

    }

    fp = fopen("cgamem.mif", "w");

    // Выгрузка MIF
    fprintf(fp, "WIDTH=8;\n");
    fprintf(fp, "DEPTH=8192;\n");
    fprintf(fp, "ADDRESS_RADIX=HEX;\n");
    fprintf(fp, "DATA_RADIX=HEX;\n");
    fprintf(fp, "CONTENT BEGIN\n");

    px = py = 0;

    // Выгрузка экрана
    for (int i = 0; i < 4096; i += 2) {

        fprintf(fp, "  %04x: %02x;\n", i,   display[py][px]);
        fprintf(fp, "  %04x: %02x;\n", i+1, 0x0F);

        px = (px + 1) % 80;
        if (px == 0) py++;
        if (py == 25) py = 0;
    }

    // Выгрузка шрифтов
    for (int i = 0; i < 4096; i++) {
        fprintf(fp, "  %04x: %02x;\n", i + 4096, fnt[i]);
    }

    fprintf(fp, "END;\n");
    fclose(fp);

    while (app.poll()) { }
}
