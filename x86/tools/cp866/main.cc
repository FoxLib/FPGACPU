#include "screen.cc"

int main(int argc, char** argv) {

    screen app(640, 480);

    uint8_t fnt[4096];
    FILE* fp = fopen("font-2.fnt", "rb");
    fread(fnt, 1, 4096, fp);
    fclose(fp);

    for (int py = 0; py < 8; py++)
    for (int px = 0; px < 32; px++) {

        int ch = 32*py + px;
        for (int y = 0; y < 16; y++)
        for (int x = 0; x < 8; x++)
            for (int k = 0; k < 4; k++)
                app.pset(16*px + 2*x + (k/2), 32*py + 2*y + (k&1), fnt[ch*16 + y] & (1 << (7-x)) ? 0xffffff : 0);

    }

    while (app.poll()) {
    }
}
