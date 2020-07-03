#include <SDL.h>

#include "ui.h"

/** Глобальные переменные ----------------------------------------------
 */

int _window_width,
    _window_height,
    _window_flip,
    _color_fore,
    _color_back;
int _keycode;

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


// Получение XT-кода
int get_key(SDL_Event event) {

    /* Получение ссылки на структуру с данными о нажатой клавише */
    SDL_KeyboardEvent * eventkey = & event.key;

    int xt = 0;
    int k = eventkey->keysym.scancode;

    //printf("%d ", k);
    switch (k) {

        /* A */ case 0x26: xt = 0x1E; break;
        /* B */ case 0x38: xt = 0x30; break;
        /* C */ case 0x36: xt = 0x2E; break;
        /* D */ case 0x28: xt = 0x20; break;
        /* E */ case 0x1a: xt = 0x12; break;
        /* F */ case 0x29: xt = 0x21; break;
        /* G */ case 0x2a: xt = 0x22; break;
        /* H */ case 0x2b: xt = 0x23; break;
        /* I */ case 0x1f: xt = 0x17; break;
        /* J */ case 0x2c: xt = 0x24; break;
        /* K */ case 0x2d: xt = 0x25; break;
        /* L */ case 0x2e: xt = 0x26; break;
        /* M */ case 0x3a: xt = 0x32; break;
        /* N */ case 0x39: xt = 0x31; break;
        /* O */ case 0x20: xt = 0x18; break;
        /* P */ case 0x21: xt = 0x19; break;
        /* Q */ case 0x18: xt = 0x10; break;
        /* R */ case 0x1b: xt = 0x13; break;
        /* S */ case 0x27: xt = 0x1F; break;
        /* T */ case 0x1c: xt = 0x14; break;
        /* U */ case 0x1e: xt = 0x16; break;
        /* V */ case 0x37: xt = 0x2F; break;
        /* W */ case 0x19: xt = 0x11; break;
        /* X */ case 0x35: xt = 0x2D; break;
        /* Y */ case 0x1d: xt = 0x15; break;
        /* Z */ case 0x34: xt = 0x2C; break;

        /* 0 */ case 0x13: xt = 0x0B; break;
        /* 1 */ case 0x0A: xt = 0x02; break;
        /* 2 */ case 0x0B: xt = 0x03; break;
        /* 3 */ case 0x0C: xt = 0x04; break;
        /* 4 */ case 0x0D: xt = 0x05; break;
        /* 5 */ case 0x0E: xt = 0x06; break;
        /* 6 */ case 0x0F: xt = 0x07; break;
        /* 7 */ case 0x10: xt = 0x08; break;
        /* 8 */ case 0x11: xt = 0x09; break;
        /* 9 */ case 0x12: xt = 0x0A; break;

        /* ~ */ case 0x31: xt = 0x29; break;
        /* - */ case 0x14: xt = 0x0C; break;
        /* = */ case 0x15: xt = 0x0D; break;
        /* \ */ case 0x33: xt = 0x2B; break;
        /* [ */ case 0x22: xt = 0x1A; break;
        /* ] */ case 0x23: xt = 0x1B; break;
        /* ; */ case 0x2f: xt = 0x27; break;
        /* ' */ case 0x30: xt = 0x28; break;
        /* , */ case 0x3b: xt = 0x33; break;
        /* . */ case 0x3c: xt = 0x34; break;
        /* / */ case 0x3d: xt = 0x35; break;

        /* bs */ case 0x16: xt = 0x0E; break; // Back Space
        /* sp */ case 0x41: xt = 0x39; break; // Space
        /* tb */ case 0x17: xt = 0x0F; break; // Tab
        /* ls */ case 0x32: xt = 0x2A; break; // Left Shift
        /* lc */ case 0x25: xt = 0x1D; break; // Left Ctrl
        /* la */ case 0x40: xt = 0x38; break; // Left Alt
        /* en */ case 0x24: xt = 0x1C; break; // Enter
        /* es */ case 0x09: xt = 0x01; break; // Escape

        /* F1  */ case 67: xt = 0x3B; break;
        /* F2  */ case 68: xt = 0x3C; break;
        /* F3  */ case 69: xt = 0x3D; break;
        /* F4  */ case 70: xt = 0x3E; break;
        /* F5  */ case 71: xt = 0x3F; break;
        /* F6  */ case 72: xt = 0x40; break;
        /* F7  */ case 73: xt = 0x41; break;
        /* F8  */ case 74: xt = 0x42; break;
        /* F9  */ case 75: xt = 0x43; break;
        /* F10 */ case 76: xt = 0x44; break;
        /* F11 */ case 95: xt = 0x57; break; // Не проверено
        /* F12 */ case 96: xt = 0x58; break;

        // ---------------------------------------------
        // Специальные (не так же как в реальном железе)
        // ---------------------------------------------

        /* UP  */  case 0x6F: xt = 0x60; break;
        /* RT  */  case 0x72: xt = 0x61; break;
        /* DN  */  case 0x74: xt = 0x62; break;
        /* LF  */  case 0x71: xt = 0x64; break;
        /* Home */ case 0x6E: xt = 0x6E; break;
        /* End  */ case 0x73: xt = 0x6F; break;
        /* PgUp */ case 0x70: xt = 0x55; break;
        /* PgDn */ case 0x75: xt = 0x56; break;
        /* Del  */ case 0x77: xt = 0x59; break;
        /* Ins  */ case 0x76: xt = 0x5A; break;
        /* NLock*/ case 0x4D: xt = 0x45; break;
        /* Esc  */ case 0x08: xt = 0x01; break;

        default: return -k;
    }

    /* Получить скан-код клавиш */
    return xt;
}

int kbcode() { return _keycode; }

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

                case SDL_KEYDOWN: eventlist |= KEYDOWN; _keycode = get_key(event); break;
                case SDL_KEYUP:   eventlist |= KEYUP;   _keycode = get_key(event); break;

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
