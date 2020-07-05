#include <SDL.h>

#include "ui.h"

/** Глобальные переменные ----------------------------------------------
 */

int _window_width,
    _window_height,
    _window_flip,
    _color_fore,
    _color_back;
int _keycode,
    _pressed;

SDL_Surface* _screen_surface;

/** Реализация ---------------------------------------------------------
 */

// Обработчик кадра
uint windowtimer(uint interval, void *param) {

    SDL_Event     event;
    SDL_UserEvent userevent;

    // Создать новый Event
    userevent.type  = SDL_USEREVENT;
    userevent.code  = 0;
    userevent.data1 = NULL;
    userevent.data2 = NULL;

    event.type = SDL_USEREVENT;
    event.user = userevent;

    SDL_PushEvent(& event);
    return (interval);
}

// Открыть окно
void startup(const char* name, int w, int h) {

    _window_width  = w;
    _window_height = h;

    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
    SDL_EnableUNICODE(1);

    _screen_surface = SDL_SetVideoMode(w, h, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
    SDL_WM_SetCaption(name, 0);
    SDL_AddTimer(20, windowtimer, NULL);

    color(15, 0);
}

// Установка цвета
void color(int fr, int bg) {

    _color_fore = fr;
    _color_back = bg;
}

// Установка точки
void pset(int x, int y, int cl) {

    if (x >= 0 && x < 640 && y >= 0 && y < 400) {

        // Рисовать крупный пиксель
        for (int i = 0; i < 4; i++) {

            int offset  = 2*(y*_window_width + x);
                offset += (i>>1)*_window_width + (i&1);

            ( (Uint32*)_screen_surface->pixels )[ offset ] = dospalette[cl & 255];
        }

        _window_flip = 1;
    }
}

// Печать символа в точке (col, row) с определенным цветом (0..255)
void pchar(int col, int row, unsigned char ch, int fr, int bg) {

    for (int i = 0; i < 16; i++)
    for (int j = 0; j < 8; j++)
        pset(8*col + j, 16*row + i, biosfont8x16[ch][i] & (1 << (7 ^ j)) ? fr : bg);
}

// Печать строки без переносов телетайпа
void pout(int col, int row, const char* s) {

    int i = 0;
    while (s[i]) {
        pchar(col, row, s[i], _color_fore, _color_back);
        col++;
        if (col >= 80) { row++; col = 0; }
        i++;
    }
}


// Получение AT&T-кода
int get_key(SDL_Event event) {

    /* Получение ссылки на структуру с данными о нажатой клавише */
    SDL_KeyboardEvent * eventkey = & event.key;

    int xt = 0;
    int k = eventkey->keysym.scancode;

    switch (k) {

        /* A */ case 0x26: xt = 0x1C; break;
        /* B */ case 0x38: xt = 0x32; break;
        /* C */ case 0x36: xt = 0x21; break;
        /* D */ case 0x28: xt = 0x23; break;
        /* E */ case 0x1a: xt = 0x24; break;
        /* F */ case 0x29: xt = 0x2B; break;
        /* G */ case 0x2a: xt = 0x34; break;
        /* H */ case 0x2b: xt = 0x33; break;
        /* I */ case 0x1f: xt = 0x43; break;
        /* J */ case 0x2c: xt = 0x3B; break;
        /* K */ case 0x2d: xt = 0x42; break;
        /* L */ case 0x2e: xt = 0x4B; break;
        /* M */ case 0x3a: xt = 0x3A; break;
        /* N */ case 0x39: xt = 0x31; break;
        /* O */ case 0x20: xt = 0x44; break;
        /* P */ case 0x21: xt = 0x4D; break;
        /* Q */ case 0x18: xt = 0x15; break;
        /* R */ case 0x1b: xt = 0x2D; break;
        /* S */ case 0x27: xt = 0x1B; break;
        /* T */ case 0x1c: xt = 0x2C; break;
        /* U */ case 0x1e: xt = 0x3C; break;
        /* V */ case 0x37: xt = 0x2A; break;
        /* W */ case 0x19: xt = 0x1D; break;
        /* X */ case 0x35: xt = 0x22; break;
        /* Y */ case 0x1d: xt = 0x35; break;
        /* Z */ case 0x34: xt = 0x1A; break;

        /* 0 */ case 0x13: xt = 0x45; break;
        /* 1 */ case 0x0A: xt = 0x16; break;
        /* 2 */ case 0x0B: xt = 0x1E; break;
        /* 3 */ case 0x0C: xt = 0x26; break;
        /* 4 */ case 0x0D: xt = 0x25; break;
        /* 5 */ case 0x0E: xt = 0x2E; break;
        /* 6 */ case 0x0F: xt = 0x36; break;
        /* 7 */ case 0x10: xt = 0x3D; break;
        /* 8 */ case 0x11: xt = 0x3E; break;
        /* 9 */ case 0x12: xt = 0x46; break;

        /* ~ */ case 0x31: xt = 0x0E; break;
        /* - */ case 0x14: xt = 0x4E; break;
        /* = */ case 0x15: xt = 0x55; break;
        /* \ */ case 0x33: xt = 0x5D; break;
        /* [ */ case 0x22: xt = 0x54; break;
        /* ] */ case 0x23: xt = 0x5B; break;
        /* ; */ case 0x2f: xt = 0x4C; break;
        /* ' */ case 0x30: xt = 0x52; break;
        /* , */ case 0x3b: xt = 0x41; break;
        /* . */ case 0x3c: xt = 0x49; break;
        /* / */ case 0x3d: xt = 0x4A; break;

        /* bs */ case 0x16: xt = 0x66; break; // Back Space
        /* sp */ case 0x41: xt = 0x29; break; // Space
        /* tb */ case 0x17: xt = 0x0D; break; // Tab
        /* ls */ case 0x32: xt = 0x12; break; // Left Shift
        /* lc */ case 0x25: xt = 0x14; break; // Left Ctrl
        /* la */ case 0x40: xt = 0x11; break; // Left Alt
        /* en */ case 0x24: xt = 0x5A; break; // Enter
        /* es */ case 0x09: xt = 0x76; break; // Escape

        /* F1  */ case 67: xt = 0x05; break;
        /* F2  */ case 68: xt = 0x06; break;
        /* F3  */ case 69: xt = 0x04; break;
        /* F4  */ case 70: xt = 0x0C; break;
        /* F5  */ case 71: xt = 0x03; break;
        /* F6  */ case 72: xt = 0x0B; break;
        /* F7  */ case 73: xt = 0x83; break;
        /* F8  */ case 74: xt = 0x0A; break;
        /* F9  */ case 75: xt = 0x01; break;
        /* F10 */ case 76: xt = 0x09; break;
        /* F11 */ case 95: xt = 0x78; break; // Не проверено
        /* F12 */ case 96: xt = 0x07; break;

        // ---------------------------------------------
        // Специальные
        // ---------------------------------------------

        /* UP  */  case 0x6F: xt = 0x75E0; break;
        /* RT  */  case 0x72: xt = 0x74E0; break;
        /* DN  */  case 0x74: xt = 0x72E0; break;
        /* LF  */  case 0x71: xt = 0x6BE0; break;
        /* Home */ case 0x6E: xt = 0x6CE0; break;
        /* End  */ case 0x73: xt = 0x69E0; break;
        /* PgUp */ case 0x70: xt = 0x7DE0; break;
        /* PgDn */ case 0x75: xt = 0x7AE0; break;
        /* Del  */ case 0x77: xt = 0x71E0; break;
        /* Ins  */ case 0x76: xt = 0x70E0; break;
        /* NLock*/ case 0x4D: xt = 0x0077; break;
        /* Esc  */ case 0x08: xt = 0x0076; break;

        default: return -k;
    }

    /* Получить скан-код клавиш */
    return xt;
}

int kbcode() { return _keycode; }
int kbpressed() { return _pressed; }

// Отслеживание событий SDL
int mainloop() {

    SDL_Event event;
    int       eventlist = 0;

    // Выйти как только появится событие(я)
    while (eventlist == 0) {

        // Отработка пула прерываний
        while (SDL_PollEvent(& event)) {

            switch (event.type) {

                case SDL_QUIT:
                    return 0;

                case SDL_KEYDOWN: eventlist |= KEYDOWN; _keycode = get_key(event); _pressed = 1; break;
                case SDL_KEYUP:   eventlist |= KEYUP;   _keycode = get_key(event); _pressed = 0; break;

                case SDL_USEREVENT:
                    eventlist |= FPS;
                    break;
            }
        }

        // Есть обновление экрана
        if (_window_flip && (eventlist & FPS)) {
            _window_flip = 0;
            SDL_Flip(_screen_surface);
        }

        SDL_Delay(1);
    }

    return eventlist;
}
