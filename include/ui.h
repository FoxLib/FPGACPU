#ifndef UI_MODULEFILE
#define UI_MODULEFILE

#include <SDL.h>

enum EVENTYPES {
    FPS     = 1,
    KEYDOWN = 2,
    KEYUP   = 4
};

// Прототипы функции
void    startup(const char* name, int w, int h);
int     mainloop();
void    pset(int x, int y, int cl);
void    pchar(int col, int row, unsigned char ch, int fr, int bg);
void    color(int fr, int bg);
void    pout(int col, int row, const char* s);
int     get_key(SDL_Event event);
int     kbcode();

// 8x8
static const unsigned char biosfont8x8[256][8] = {

    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x7e, 0x81, 0xa5, 0x81, 0xbd, 0x99, 0x81, 0x7e},
    {0x7e, 0xff, 0xdb, 0xff, 0xc3, 0xe7, 0xff, 0x7e},
    {0x6c, 0xfe, 0xfe, 0xfe, 0x7c, 0x38, 0x10, 0x00},
    {0x10, 0x38, 0x7c, 0xfe, 0x7c, 0x38, 0x10, 0x00},
    {0x38, 0x7c, 0x38, 0xfe, 0xfe, 0x7c, 0x38, 0x7c},
    {0x10, 0x10, 0x38, 0x7c, 0xfe, 0x7c, 0x38, 0x7c},
    {0x00, 0x00, 0x18, 0x3c, 0x3c, 0x18, 0x00, 0x00},
    {0xff, 0xff, 0xe7, 0xc3, 0xc3, 0xe7, 0xff, 0xff},
    {0x00, 0x3c, 0x66, 0x42, 0x42, 0x66, 0x3c, 0x00},
    {0xff, 0xc3, 0x99, 0xbd, 0xbd, 0x99, 0xc3, 0xff},
    {0x0f, 0x07, 0x0f, 0x7d, 0xcc, 0xcc, 0xcc, 0x78},
    {0x3c, 0x66, 0x66, 0x66, 0x3c, 0x18, 0x7e, 0x18},
    {0x3f, 0x33, 0x3f, 0x30, 0x30, 0x70, 0xf0, 0xe0},
    {0x7f, 0x63, 0x7f, 0x63, 0x63, 0x67, 0xe6, 0xc0},
    {0x99, 0x5a, 0x3c, 0xe7, 0xe7, 0x3c, 0x5a, 0x99},
    {0x80, 0xe0, 0xf8, 0xfe, 0xf8, 0xe0, 0x80, 0x00},
    {0x02, 0x0e, 0x3e, 0xfe, 0x3e, 0x0e, 0x02, 0x00},
    {0x18, 0x3c, 0x7e, 0x18, 0x18, 0x7e, 0x3c, 0x18},
    {0x66, 0x66, 0x66, 0x66, 0x66, 0x00, 0x66, 0x00},
    {0x7f, 0xdb, 0xdb, 0x7b, 0x1b, 0x1b, 0x1b, 0x00},
    {0x3e, 0x63, 0x38, 0x6c, 0x6c, 0x38, 0xcc, 0x78},
    {0x00, 0x00, 0x00, 0x00, 0x7e, 0x7e, 0x7e, 0x00},
    {0x18, 0x3c, 0x7e, 0x18, 0x7e, 0x3c, 0x18, 0xff},
    {0x18, 0x3c, 0x7e, 0x18, 0x18, 0x18, 0x18, 0x00},
    {0x18, 0x18, 0x18, 0x18, 0x7e, 0x3c, 0x18, 0x00},
    {0x00, 0x18, 0x0c, 0xfe, 0x0c, 0x18, 0x00, 0x00},
    {0x00, 0x30, 0x60, 0xfe, 0x60, 0x30, 0x00, 0x00},
    {0x00, 0x00, 0xc0, 0xc0, 0xc0, 0xfe, 0x00, 0x00},
    {0x00, 0x24, 0x66, 0xff, 0x66, 0x24, 0x00, 0x00},
    {0x00, 0x18, 0x3c, 0x7e, 0xff, 0xff, 0x00, 0x00},
    {0x00, 0xff, 0xff, 0x7e, 0x3c, 0x18, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x30, 0x78, 0x78, 0x30, 0x30, 0x00, 0x30, 0x00},
    {0x6c, 0x6c, 0x6c, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x6c, 0x6c, 0xfe, 0x6c, 0xfe, 0x6c, 0x6c, 0x00},
    {0x30, 0x7c, 0xc0, 0x78, 0x0c, 0xf8, 0x30, 0x00},
    {0x00, 0xc6, 0xcc, 0x18, 0x30, 0x66, 0xc6, 0x00},
    {0x38, 0x6c, 0x38, 0x76, 0xdc, 0xcc, 0x76, 0x00},
    {0x60, 0x60, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x18, 0x30, 0x60, 0x60, 0x60, 0x30, 0x18, 0x00},
    {0x60, 0x30, 0x18, 0x18, 0x18, 0x30, 0x60, 0x00},
    {0x00, 0x66, 0x3c, 0xff, 0x3c, 0x66, 0x00, 0x00},
    {0x00, 0x30, 0x30, 0xfc, 0x30, 0x30, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x60},
    {0x00, 0x00, 0x00, 0xfc, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x00},
    {0x06, 0x0c, 0x18, 0x30, 0x60, 0xc0, 0x80, 0x00},
    {0x7c, 0xc6, 0xce, 0xde, 0xf6, 0xe6, 0x7c, 0x00},
    {0x30, 0x70, 0x30, 0x30, 0x30, 0x30, 0xfc, 0x00},
    {0x78, 0xcc, 0x0c, 0x38, 0x60, 0xcc, 0xfc, 0x00},
    {0x78, 0xcc, 0x0c, 0x38, 0x0c, 0xcc, 0x78, 0x00},
    {0x1c, 0x3c, 0x6c, 0xcc, 0xfe, 0x0c, 0x1e, 0x00},
    {0xfc, 0xc0, 0xf8, 0x0c, 0x0c, 0xcc, 0x78, 0x00},
    {0x38, 0x60, 0xc0, 0xf8, 0xcc, 0xcc, 0x78, 0x00},
    {0xfc, 0xcc, 0x0c, 0x18, 0x30, 0x30, 0x30, 0x00},
    {0x78, 0xcc, 0xcc, 0x78, 0xcc, 0xcc, 0x78, 0x00},
    {0x78, 0xcc, 0xcc, 0x7c, 0x0c, 0x18, 0x70, 0x00},
    {0x00, 0x30, 0x30, 0x00, 0x00, 0x30, 0x30, 0x00},
    {0x00, 0x30, 0x30, 0x00, 0x00, 0x30, 0x30, 0x60},
    {0x18, 0x30, 0x60, 0xc0, 0x60, 0x30, 0x18, 0x00},
    {0x00, 0x00, 0xfc, 0x00, 0x00, 0xfc, 0x00, 0x00},
    {0x60, 0x30, 0x18, 0x0c, 0x18, 0x30, 0x60, 0x00},
    {0x78, 0xcc, 0x0c, 0x18, 0x30, 0x00, 0x30, 0x00},
    {0x7c, 0xc6, 0xde, 0xde, 0xde, 0xc0, 0x78, 0x00},
    {0x30, 0x78, 0xcc, 0xcc, 0xfc, 0xcc, 0xcc, 0x00},
    {0xfc, 0x66, 0x66, 0x7c, 0x66, 0x66, 0xfc, 0x00},
    {0x3c, 0x66, 0xc0, 0xc0, 0xc0, 0x66, 0x3c, 0x00},
    {0xf8, 0x6c, 0x66, 0x66, 0x66, 0x6c, 0xf8, 0x00},
    {0xfe, 0x62, 0x68, 0x78, 0x68, 0x62, 0xfe, 0x00},
    {0xfe, 0x62, 0x68, 0x78, 0x68, 0x60, 0xf0, 0x00},
    {0x3c, 0x66, 0xc0, 0xc0, 0xce, 0x66, 0x3e, 0x00},
    {0xcc, 0xcc, 0xcc, 0xfc, 0xcc, 0xcc, 0xcc, 0x00},
    {0x78, 0x30, 0x30, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0x1e, 0x0c, 0x0c, 0x0c, 0xcc, 0xcc, 0x78, 0x00},
    {0xe6, 0x66, 0x6c, 0x78, 0x6c, 0x66, 0xe6, 0x00},
    {0xf0, 0x60, 0x60, 0x60, 0x62, 0x66, 0xfe, 0x00},
    {0xc6, 0xee, 0xfe, 0xfe, 0xd6, 0xc6, 0xc6, 0x00},
    {0xc6, 0xe6, 0xf6, 0xde, 0xce, 0xc6, 0xc6, 0x00},
    {0x38, 0x6c, 0xc6, 0xc6, 0xc6, 0x6c, 0x38, 0x00},
    {0xfc, 0x66, 0x66, 0x7c, 0x60, 0x60, 0xf0, 0x00},
    {0x78, 0xcc, 0xcc, 0xcc, 0xdc, 0x78, 0x1c, 0x00},
    {0xfc, 0x66, 0x66, 0x7c, 0x6c, 0x66, 0xe6, 0x00},
    {0x78, 0xcc, 0xe0, 0x70, 0x1c, 0xcc, 0x78, 0x00},
    {0xfc, 0xb4, 0x30, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xfc, 0x00},
    {0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0x78, 0x30, 0x00},
    {0xc6, 0xc6, 0xc6, 0xd6, 0xfe, 0xee, 0xc6, 0x00},
    {0xc6, 0xc6, 0x6c, 0x38, 0x38, 0x6c, 0xc6, 0x00},
    {0xcc, 0xcc, 0xcc, 0x78, 0x30, 0x30, 0x78, 0x00},
    {0xfe, 0xc6, 0x8c, 0x18, 0x32, 0x66, 0xfe, 0x00},
    {0x78, 0x60, 0x60, 0x60, 0x60, 0x60, 0x78, 0x00},
    {0xc0, 0x60, 0x30, 0x18, 0x0c, 0x06, 0x02, 0x00},
    {0x78, 0x18, 0x18, 0x18, 0x18, 0x18, 0x78, 0x00},
    {0x10, 0x38, 0x6c, 0xc6, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff},
    {0x30, 0x30, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x78, 0x0c, 0x7c, 0xcc, 0x76, 0x00},
    {0xe0, 0x60, 0x60, 0x7c, 0x66, 0x66, 0xdc, 0x00},
    {0x00, 0x00, 0x78, 0xcc, 0xc0, 0xcc, 0x78, 0x00},
    {0x1c, 0x0c, 0x0c, 0x7c, 0xcc, 0xcc, 0x76, 0x00},
    {0x00, 0x00, 0x78, 0xcc, 0xfc, 0xc0, 0x78, 0x00},
    {0x38, 0x6c, 0x60, 0xf0, 0x60, 0x60, 0xf0, 0x00},
    {0x00, 0x00, 0x76, 0xcc, 0xcc, 0x7c, 0x0c, 0xf8},
    {0xe0, 0x60, 0x6c, 0x76, 0x66, 0x66, 0xe6, 0x00},
    {0x30, 0x00, 0x70, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0x0c, 0x00, 0x0c, 0x0c, 0x0c, 0xcc, 0xcc, 0x78},
    {0xe0, 0x60, 0x66, 0x6c, 0x78, 0x6c, 0xe6, 0x00},
    {0x70, 0x30, 0x30, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0x00, 0x00, 0xcc, 0xfe, 0xfe, 0xd6, 0xc6, 0x00},
    {0x00, 0x00, 0xf8, 0xcc, 0xcc, 0xcc, 0xcc, 0x00},
    {0x00, 0x00, 0x78, 0xcc, 0xcc, 0xcc, 0x78, 0x00},
    {0x00, 0x00, 0xdc, 0x66, 0x66, 0x7c, 0x60, 0xf0},
    {0x00, 0x00, 0x76, 0xcc, 0xcc, 0x7c, 0x0c, 0x1e},
    {0x00, 0x00, 0xdc, 0x76, 0x66, 0x60, 0xf0, 0x00},
    {0x00, 0x00, 0x7c, 0xc0, 0x78, 0x0c, 0xf8, 0x00},
    {0x10, 0x30, 0x7c, 0x30, 0x30, 0x34, 0x18, 0x00},
    {0x00, 0x00, 0xcc, 0xcc, 0xcc, 0xcc, 0x76, 0x00},
    {0x00, 0x00, 0xcc, 0xcc, 0xcc, 0x78, 0x30, 0x00},
    {0x00, 0x00, 0xc6, 0xd6, 0xfe, 0xfe, 0x6c, 0x00},
    {0x00, 0x00, 0xc6, 0x6c, 0x38, 0x6c, 0xc6, 0x00},
    {0x00, 0x00, 0xcc, 0xcc, 0xcc, 0x7c, 0x0c, 0xf8},
    {0x00, 0x00, 0xfc, 0x98, 0x30, 0x64, 0xfc, 0x00},
    {0x1c, 0x30, 0x30, 0xe0, 0x30, 0x30, 0x1c, 0x00},
    {0x18, 0x18, 0x18, 0x00, 0x18, 0x18, 0x18, 0x00},
    {0xe0, 0x30, 0x30, 0x1c, 0x30, 0x30, 0xe0, 0x00},
    {0x76, 0xdc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x10, 0x38, 0x6c, 0xc6, 0xc6, 0xfe, 0x00},
    {0x1e, 0x36, 0x66, 0x66, 0x7e, 0x66, 0x66, 0x00},
    {0x7c, 0x60, 0x60, 0x7c, 0x66, 0x66, 0x7c, 0x00},
    {0x7c, 0x66, 0x66, 0x7c, 0x66, 0x66, 0x7c, 0x00},
    {0x7e, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x00},
    {0x38, 0x6c, 0x6c, 0x6c, 0x6c, 0x6c, 0xfe, 0xc6},
    {0x7e, 0x60, 0x60, 0x7c, 0x60, 0x60, 0x7e, 0x00},
    {0xdb, 0xdb, 0x7e, 0x3c, 0x7e, 0xdb, 0xdb, 0x00},
    {0x3c, 0x66, 0x06, 0x1c, 0x06, 0x66, 0x3c, 0x00},
    {0x66, 0x66, 0x6e, 0x7e, 0x76, 0x66, 0x66, 0x00},
    {0x3c, 0x66, 0x6e, 0x7e, 0x76, 0x66, 0x66, 0x00},
    {0x66, 0x6c, 0x78, 0x70, 0x78, 0x6c, 0x66, 0x00},
    {0x1e, 0x36, 0x66, 0x66, 0x66, 0x66, 0x66, 0x00},
    {0xc6, 0xee, 0xfe, 0xfe, 0xd6, 0xc6, 0xc6, 0x00},
    {0x66, 0x66, 0x66, 0x7e, 0x66, 0x66, 0x66, 0x00},
    {0x3c, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3c, 0x00},
    {0x7e, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x00},
    {0x7c, 0x66, 0x66, 0x66, 0x7c, 0x60, 0x60, 0x00},
    {0x3c, 0x66, 0x60, 0x60, 0x60, 0x66, 0x3c, 0x00},
    {0x7e, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00},
    {0x66, 0x66, 0x66, 0x3e, 0x06, 0x66, 0x3c, 0x00},
    {0x7e, 0xdb, 0xdb, 0xdb, 0x7e, 0x18, 0x18, 0x00},
    {0x66, 0x66, 0x3c, 0x18, 0x3c, 0x66, 0x66, 0x00},
    {0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x7f, 0x03},
    {0x66, 0x66, 0x66, 0x3e, 0x06, 0x06, 0x06, 0x00},
    {0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xff, 0x00},
    {0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xdb, 0xff, 0x03},
    {0xe0, 0x60, 0x60, 0x7c, 0x66, 0x66, 0x7c, 0x00},
    {0xc6, 0xc6, 0xc6, 0xf6, 0xde, 0xde, 0xf6, 0x00},
    {0x60, 0x60, 0x60, 0x7c, 0x66, 0x66, 0x7c, 0x00},
    {0x78, 0x8c, 0x06, 0x3e, 0x06, 0x8c, 0x78, 0x00},
    {0xce, 0xdb, 0xdb, 0xfb, 0xdb, 0xdb, 0xce, 0x00},
    {0x3e, 0x66, 0x66, 0x66, 0x3e, 0x36, 0x66, 0x00},
    {0x00, 0x00, 0x78, 0x0c, 0x7c, 0xcc, 0x76, 0x00},
    {0x00, 0x3c, 0x60, 0x3c, 0x66, 0x66, 0x3c, 0x00},
    {0x00, 0x00, 0x7c, 0x66, 0x7c, 0x66, 0x7c, 0x00},
    {0x00, 0x00, 0x7e, 0x60, 0x60, 0x60, 0x60, 0x00},
    {0x00, 0x00, 0x3c, 0x6c, 0x6c, 0x6c, 0xfe, 0xc6},
    {0x00, 0x00, 0x3c, 0x66, 0x7e, 0x60, 0x3c, 0x00},
    {0x00, 0x00, 0xdb, 0x7e, 0x3c, 0x7e, 0xdb, 0x00},
    {0x00, 0x00, 0x3c, 0x66, 0x0c, 0x66, 0x3c, 0x00},
    {0x00, 0x00, 0x66, 0x6e, 0x7e, 0x76, 0x66, 0x00},
    {0x00, 0x18, 0x66, 0x6e, 0x7e, 0x76, 0x66, 0x00},
    {0x00, 0x00, 0x66, 0x6c, 0x78, 0x6c, 0x66, 0x00},
    {0x00, 0x00, 0x1e, 0x36, 0x66, 0x66, 0x66, 0x00},
    {0x00, 0x00, 0xc6, 0xfe, 0xfe, 0xd6, 0xc6, 0x00},
    {0x00, 0x00, 0x66, 0x66, 0x7e, 0x66, 0x66, 0x00},
    {0x00, 0x00, 0x3c, 0x66, 0x66, 0x66, 0x3c, 0x00},
    {0x00, 0x00, 0x7e, 0x66, 0x66, 0x66, 0x66, 0x00},
    {0x11, 0x44, 0x11, 0x44, 0x11, 0x44, 0x11, 0x44},
    {0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa},
    {0xdd, 0x77, 0xdd, 0x77, 0xdd, 0x77, 0xdd, 0x77},
    {0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0x18, 0x18, 0xf8, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0xf8, 0x18, 0xf8, 0x18, 0x18, 0x18, 0x18},
    {0x36, 0x36, 0x36, 0xf6, 0x36, 0x36, 0x36, 0x36},
    {0x00, 0x00, 0x00, 0xfe, 0x36, 0x36, 0x36, 0x36},
    {0x00, 0xf8, 0x18, 0xf8, 0x18, 0x18, 0x18, 0x18},
    {0x36, 0xf6, 0x06, 0xf6, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36, 0x36},
    {0x00, 0xfe, 0x06, 0xf6, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0xf6, 0x06, 0xfe, 0x00, 0x00, 0x00, 0x00},
    {0x36, 0x36, 0x36, 0xfe, 0x00, 0x00, 0x00, 0x00},
    {0x18, 0xf8, 0x18, 0xf8, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0xf8, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0x18, 0x18, 0x1f, 0x00, 0x00, 0x00, 0x00},
    {0x18, 0x18, 0x18, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0xff, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0x18, 0x18, 0x1f, 0x18, 0x18, 0x18, 0x18},
    {0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x18, 0x18, 0x18, 0xff, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0x1f, 0x18, 0x1f, 0x18, 0x18, 0x18, 0x18},
    {0x36, 0x36, 0x36, 0x37, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0x37, 0x30, 0x3f, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x3f, 0x30, 0x37, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0xf7, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0xff, 0x00, 0xf7, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0x37, 0x30, 0x37, 0x36, 0x36, 0x36, 0x36},
    {0x00, 0xff, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x36, 0xf7, 0x00, 0xf7, 0x36, 0x36, 0x36, 0x36},
    {0x18, 0xff, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x36, 0x36, 0x36, 0xff, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0xff, 0x00, 0xff, 0x18, 0x18, 0x18, 0x18},
    {0x00, 0x00, 0x00, 0xff, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0x36, 0x36, 0x3f, 0x00, 0x00, 0x00, 0x00},
    {0x18, 0x1f, 0x18, 0x1f, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x1f, 0x18, 0x1f, 0x18, 0x18, 0x18, 0x18},
    {0x00, 0x00, 0x00, 0x3f, 0x36, 0x36, 0x36, 0x36},
    {0x36, 0x36, 0x36, 0xff, 0x36, 0x36, 0x36, 0x36},
    {0x18, 0xff, 0x18, 0xff, 0x18, 0x18, 0x18, 0x18},
    {0x18, 0x18, 0x18, 0xf8, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x1f, 0x18, 0x18, 0x18, 0x18},
    {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
    {0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff},
    {0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0},
    {0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f},
    {0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x7c, 0x66, 0x66, 0x7c, 0x60, 0x00},
    {0x00, 0x00, 0x3c, 0x66, 0x60, 0x66, 0x3c, 0x00},
    {0x00, 0x00, 0x7e, 0x18, 0x18, 0x18, 0x18, 0x00},
    {0x00, 0x00, 0x66, 0x66, 0x3e, 0x06, 0x3c, 0x00},
    {0x00, 0x00, 0x7e, 0xdb, 0xdb, 0x7e, 0x18, 0x00},
    {0x00, 0x00, 0x66, 0x3c, 0x18, 0x3c, 0x66, 0x00},
    {0x00, 0x00, 0x66, 0x66, 0x66, 0x66, 0x7f, 0x03},
    {0x00, 0x00, 0x66, 0x66, 0x3e, 0x06, 0x06, 0x00},
    {0x00, 0x00, 0xdb, 0xdb, 0xdb, 0xdb, 0xff, 0x00},
    {0x00, 0x00, 0xdb, 0xdb, 0xdb, 0xdb, 0xff, 0x03},
    {0x00, 0x00, 0xe0, 0x60, 0x7c, 0x66, 0x7c, 0x00},
    {0x00, 0x00, 0xc6, 0xc6, 0xf6, 0xde, 0xf6, 0x00},
    {0x00, 0x00, 0x60, 0x60, 0x7c, 0x66, 0x7c, 0x00},
    {0x00, 0x00, 0x7c, 0x06, 0x3e, 0x06, 0x7c, 0x00},
    {0x00, 0x00, 0xce, 0xdb, 0xfb, 0xdb, 0xce, 0x00},
    {0x00, 0x00, 0x3e, 0x66, 0x3e, 0x36, 0x66, 0x00},
    {0x6c, 0xfe, 0x80, 0xf8, 0x80, 0x80, 0xfe, 0x00},
    {0x6c, 0x00, 0x7c, 0x82, 0xfe, 0x80, 0x7e, 0x00},
    {0x3c, 0x62, 0xc0, 0xf8, 0xc0, 0x62, 0x3c, 0x00},
    {0x00, 0x00, 0x3e, 0x60, 0x7c, 0x60, 0x3e, 0x00},
    {0x48, 0x78, 0x30, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0x50, 0x00, 0x70, 0x30, 0x30, 0x30, 0x78, 0x00},
    {0x00, 0x18, 0x18, 0x00, 0x7e, 0x00, 0x18, 0x18},
    {0x00, 0x76, 0xdc, 0x00, 0x76, 0xdc, 0x00, 0x00},
    {0x00, 0x38, 0x6c, 0x6c, 0x38, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x38, 0x38, 0x00, 0x00, 0x00},
    {0x03, 0x02, 0x06, 0x04, 0xcc, 0x68, 0x38, 0x10},
    {0x8b, 0xcb, 0xe8, 0xb8, 0x98, 0x88, 0x88, 0x00},
    {0x30, 0x48, 0x10, 0x20, 0x78, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x7c, 0x7c, 0x7c, 0x7c, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
};

// Шрифт 8x16
static const unsigned char biosfont8x16[256][16] = {

    /* $00 */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $01 */ {0, 0, 126, 129, 165, 165, 165, 129, 129, 189, 153, 129, 126, 0, 0, 0},
    /* $02 */ {0, 0, 126, 255, 219, 219, 219, 255, 255, 195, 231, 255, 126, 0, 0, 0},
    /* $03 */ {0, 0, 108, 254, 254, 254, 254, 254, 254, 124, 56, 16, 0, 0, 0, 0},
    /* $04 */ {0, 0, 0, 0, 16, 56, 124, 254, 124, 56, 16, 0, 0, 0, 0, 0},
    /* $05 */ {0, 0, 0, 24, 60, 60, 231, 231, 231, 24, 24, 60, 0, 0, 0, 0},
    /* $06 */ {0, 0, 0, 24, 60, 126, 255, 255, 126, 24, 24, 60, 0, 0, 0, 0},
    /* $07 */ {0, 0, 0, 0, 0, 24, 60, 60, 24, 0, 0, 0, 0, 0, 0, 0},
    /* $08 */ {255, 255, 255, 255, 255, 255, 231, 195, 195, 231, 255, 255, 255, 255, 255, 255},
    /* $09 */ {0, 0, 0, 0, 0, 60, 102, 66, 66, 102, 60, 0, 0, 0, 0, 0},
    /* $0A */ {255, 255, 255, 255, 195, 153, 189, 189, 153, 195, 255, 255, 255, 255, 255, 255},
    /* $0B */ {0, 0, 0, 30, 14, 26, 50, 120, 204, 204, 204, 120, 0, 0, 0, 0},
    /* $0C */ {0, 0, 0, 60, 102, 102, 102, 60, 24, 126, 24, 24, 0, 0, 0, 0},
    /* $0D */ {0, 0, 0, 63, 51, 63, 48, 48, 48, 112, 240, 224, 0, 0, 0, 0},
    /* $0E */ {0, 0, 0, 127, 99, 127, 99, 99, 99, 103, 231, 230, 192, 0, 0, 0},
    /* $0F */ {0, 0, 0, 24, 24, 219, 60, 231, 60, 219, 24, 24, 0, 0, 0, 0},
    /* $10 */ {0, 0, 0, 128, 192, 224, 248, 254, 248, 224, 192, 128, 0, 0, 0, 0},
    /* $11 */ {0, 0, 0, 2, 6, 14, 62, 254, 62, 14, 6, 2, 0, 0, 0, 0},
    /* $12 */ {0, 0, 0, 24, 60, 126, 24, 24, 24, 24, 24, 24, 126, 60, 24, 0},
    /* $13 */ {0, 0, 0, 102, 102, 102, 102, 102, 102, 0, 102, 102, 0, 0, 0, 0},
    /* $14 */ {0, 0, 0, 127, 219, 219, 219, 123, 27, 27, 27, 27, 0, 0, 0, 0},
    /* $15 */ {0, 0, 124, 198, 96, 56, 108, 198, 198, 108, 56, 12, 198, 124, 0, 0},
    /* $16 */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 254, 254, 254, 0, 0, 0, 0},
    /* $17 */ {0, 0, 0, 24, 60, 126, 24, 24, 24, 126, 60, 24, 126, 0, 0, 0},
    /* $18 */ {0, 0, 0, 24, 60, 126, 24, 24, 24, 24, 24, 24, 24, 24, 24, 0},
    /* $19 */ {0, 0, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 126, 60, 24, 0},
    /* $1A */ {0, 0, 0, 0, 0, 24, 12, 254, 12, 24, 0, 0, 0, 0, 0, 0},
    /* $1B */ {0, 0, 0, 0, 0, 48, 96, 254, 96, 48, 0, 0, 0, 0, 0, 0},
    /* $1C */ {0, 0, 0, 0, 0, 0, 192, 192, 192, 254, 0, 0, 0, 0, 0, 0},
    /* $1D */ {0, 0, 0, 0, 0, 40, 108, 254, 108, 40, 0, 0, 0, 0, 0, 0},
    /* $1E */ {0, 0, 0, 0, 16, 56, 56, 124, 124, 254, 254, 0, 0, 0, 0, 0},
    /* $1F */ {0, 0, 0, 254, 124, 56, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $20   */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $21 ! */ {0, 0, 24, 60, 60, 60, 60, 24, 24, 24, 0, 0, 24, 0, 0, 0},
    /* $22 " */ {0, 102, 102, 102, 102, 102, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $23 # */ {0, 0, 108, 108, 108, 254, 108, 108, 108, 254, 108, 108, 108, 0, 0, 0},
    /* $24 $ */ {24, 24, 24, 124, 198, 194, 192, 124, 6, 134, 198, 124, 24, 24, 24, 0},
    /* $25 % */ {0, 0, 0, 0, 0, 194, 198, 12, 24, 48, 102, 198, 0, 0, 0, 0},
    /* $26 & */ {0, 0, 56, 108, 108, 108, 56, 118, 220, 204, 204, 204, 118, 0, 0, 0},
    /* $27 ' */ {0, 48, 48, 48, 48, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $28 ( */ {0, 0, 12, 24, 48, 48, 48, 48, 48, 48, 48, 24, 12, 0, 0, 0},
    /* $29 ) */ {0, 0, 48, 24, 12, 12, 12, 12, 12, 12, 12, 24, 48, 0, 0, 0},
    /* $2A * */ {0, 0, 0, 0, 102, 102, 60, 255, 60, 102, 102, 0, 0, 0, 0, 0},
    /* $2B + */ {0, 0, 0, 0, 24, 24, 24, 126, 24, 24, 24, 0, 0, 0, 0, 0},
    /* $2C , */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 24, 24, 24, 48, 0, 0},
    /* $2D - */ {0, 0, 0, 0, 0, 0, 0, 254, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $2E . */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 24, 0, 0, 0},
    /* $2F / */ {0, 0, 0, 2, 6, 12, 24, 48, 96, 192, 128, 0, 0, 0, 0, 0},
    /* $30 0 */ {0, 0, 124, 198, 198, 206, 222, 246, 246, 230, 198, 198, 124, 0, 0, 0},
    /* $31 1 */ {0, 0, 24, 24, 56, 120, 24, 24, 24, 24, 24, 24, 126, 0, 0, 0},
    /* $32 2 */ {0, 0, 124, 198, 198, 6, 6, 12, 24, 48, 96, 198, 254, 0, 0, 0},
    /* $33 3 */ {0, 0, 124, 198, 6, 6, 6, 60, 6, 6, 6, 198, 124, 0, 0, 0},
    /* $34 4 */ {0, 0, 12, 28, 60, 108, 204, 204, 254, 12, 12, 12, 30, 0, 0, 0},
    /* $35 5 */ {0, 0, 254, 192, 192, 192, 252, 6, 6, 6, 6, 198, 124, 0, 0, 0},
    /* $36 6 */ {0, 0, 56, 96, 192, 192, 252, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $37 7 */ {0, 0, 254, 198, 198, 6, 6, 12, 24, 48, 48, 48, 48, 0, 0, 0},
    /* $38 8 */ {0, 0, 124, 198, 198, 198, 198, 124, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $39 9 */ {0, 0, 124, 198, 198, 198, 198, 198, 126, 6, 6, 12, 120, 0, 0, 0},
    /* $3A : */ {0, 0, 0, 24, 24, 0, 0, 0, 0, 0, 0, 24, 24, 0, 0, 0},
    /* $3B ; */ {0, 0, 0, 24, 24, 0, 0, 0, 0, 24, 24, 24, 24, 48, 0, 0},
    /* $3C < */ {0, 0, 0, 6, 12, 24, 48, 96, 48, 24, 12, 6, 0, 0, 0, 0},
    /* $3D = */ {0, 0, 0, 0, 0, 0, 126, 0, 0, 126, 0, 0, 0, 0, 0, 0},
    /* $3E > */ {0, 0, 0, 96, 48, 24, 12, 6, 12, 24, 48, 96, 0, 0, 0, 0},
    /* $3F ? */ {0, 0, 124, 198, 198, 198, 12, 24, 24, 24, 0, 24, 24, 0, 0, 0},
    /* $40 @ */ {0, 0, 124, 198, 198, 198, 222, 222, 222, 220, 192, 192, 124, 0, 0, 0},
    /* $41 A */ {0, 0, 16, 56, 108, 198, 198, 198, 254, 198, 198, 198, 198, 0, 0, 0},
    /* $42 B */ {0, 0, 252, 102, 102, 102, 102, 124, 102, 102, 102, 102, 252, 0, 0, 0},
    /* $43 C */ {0, 0, 124, 198, 198, 192, 192, 192, 192, 198, 198, 198, 124, 0, 0, 0},
    /* $44 D */ {0, 0, 252, 102, 102, 102, 102, 102, 102, 102, 102, 102, 252, 0, 0, 0},
    /* $45 E */ {0, 0, 254, 102, 98, 96, 104, 120, 104, 104, 98, 102, 254, 0, 0, 0},
    /* $46 F */ {0, 0, 254, 102, 98, 96, 104, 120, 104, 104, 96, 96, 240, 0, 0, 0},
    /* $47 G */ {0, 0, 124, 198, 198, 192, 192, 192, 222, 198, 198, 198, 124, 0, 0, 0},
    /* $48 H */ {0, 0, 198, 198, 198, 198, 198, 254, 198, 198, 198, 198, 198, 0, 0, 0},
    /* $49 I */ {0, 0, 60, 24, 24, 24, 24, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $4A J */ {0, 0, 30, 12, 12, 12, 12, 12, 12, 12, 204, 204, 120, 0, 0, 0},
    /* $4B K */ {0, 0, 230, 102, 102, 108, 108, 120, 108, 108, 102, 102, 230, 0, 0, 0},
    /* $4C L */ {0, 0, 240, 96, 96, 96, 96, 96, 96, 96, 98, 102, 254, 0, 0, 0},
    /* $4D M */ {0, 0, 198, 198, 238, 254, 254, 214, 198, 198, 198, 198, 198, 0, 0, 0},
    /* $4E N */ {0, 0, 198, 198, 230, 246, 254, 222, 206, 198, 198, 198, 198, 0, 0, 0},
    /* $4F O */ {0, 0, 124, 198, 198, 198, 198, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $50 P */ {0, 0, 252, 102, 102, 102, 102, 102, 124, 96, 96, 96, 240, 0, 0, 0},
    /* $51 Q */ {0, 0, 124, 198, 198, 198, 198, 198, 198, 214, 222, 124, 12, 0, 0, 0},
    /* $52 R */ {0, 0, 252, 102, 102, 102, 102, 124, 108, 102, 102, 102, 230, 0, 0, 0},
    /* $53 S */ {0, 0, 124, 198, 198, 198, 96, 56, 12, 198, 198, 198, 124, 0, 0, 0},
    /* $54 T */ {0, 0, 126, 126, 90, 24, 24, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $55 U */ {0, 0, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $56 V */ {0, 0, 198, 198, 198, 198, 198, 198, 198, 198, 108, 56, 16, 0, 0, 0},
    /* $57 W */ {0, 0, 198, 198, 198, 198, 198, 214, 214, 254, 124, 108, 108, 0, 0, 0},
    /* $58 X */ {0, 0, 198, 198, 198, 108, 56, 56, 56, 108, 198, 198, 198, 0, 0, 0},
    /* $59 Y */ {0, 0, 102, 102, 102, 102, 102, 60, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $5A Z */ {0, 0, 254, 198, 198, 140, 24, 48, 96, 194, 198, 198, 254, 0, 0, 0},
    /* $5B { */ {0, 0, 60, 48, 48, 48, 48, 48, 48, 48, 48, 48, 60, 0, 0, 0},
    /* $5C \ */ {0, 0, 0, 128, 192, 224, 112, 56, 28, 14, 6, 2, 0, 0, 0, 0},
    /* $5D } */ {0, 0, 60, 12, 12, 12, 12, 12, 12, 12, 12, 12, 60, 0, 0, 0},
    /* $5E ^ */ {16, 16, 56, 108, 198, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $5F _ */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 0},
    /* $60 ` */ {48, 48, 48, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $61 a */ {0, 0, 0, 0, 0, 120, 204, 12, 124, 204, 204, 204, 118, 0, 0, 0},
    /* $62 b */ {0, 0, 224, 96, 96, 96, 120, 108, 102, 102, 102, 102, 124, 0, 0, 0},
    /* $63 c */ {0, 0, 0, 0, 0, 124, 198, 198, 192, 192, 198, 198, 124, 0, 0, 0},
    /* $64 d */ {0, 0, 28, 12, 12, 12, 60, 108, 204, 204, 204, 204, 118, 0, 0, 0},
    /* $65 e */ {0, 0, 0, 0, 0, 124, 198, 198, 254, 192, 198, 198, 124, 0, 0, 0},
    /* $66 f */ {0, 0, 56, 108, 100, 96, 240, 96, 96, 96, 96, 96, 240, 0, 0, 0},
    /* $67 g */ {0, 0, 0, 0, 0, 118, 204, 204, 204, 204, 204, 124, 12, 204, 120, 0},
    /* $68 h */ {0, 0, 224, 96, 96, 108, 118, 102, 102, 102, 102, 102, 230, 0, 0, 0},
    /* $69 i */ {0, 0, 24, 24, 0, 56, 24, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $6A j */ {0, 0, 6, 6, 0, 14, 6, 6, 6, 6, 6, 6, 102, 102, 60, 0},
    /* $6B k */ {0, 0, 224, 96, 96, 102, 102, 108, 120, 108, 102, 102, 230, 0, 0, 0},
    /* $6C l */ {0, 0, 56, 24, 24, 24, 24, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $6D m */ {0, 0, 0, 0, 0, 236, 254, 214, 214, 214, 198, 198, 198, 0, 0, 0},
    /* $6E n */ {0, 0, 0, 0, 0, 220, 102, 102, 102, 102, 102, 102, 102, 0, 0, 0},
    /* $6F o */ {0, 0, 0, 0, 0, 124, 198, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $70 p */ {0, 0, 0, 0, 0, 220, 102, 102, 102, 102, 102, 102, 124, 96, 240, 0},
    /* $71 q */ {0, 0, 0, 0, 0, 118, 204, 204, 204, 204, 204, 204, 124, 12, 30, 0},
    /* $72 r */ {0, 0, 0, 0, 0, 220, 118, 102, 96, 96, 96, 96, 240, 0, 0, 0},
    /* $73 s */ {0, 0, 0, 0, 0, 124, 198, 198, 112, 28, 198, 198, 124, 0, 0, 0},
    /* $74 t */ {0, 0, 16, 48, 48, 252, 48, 48, 48, 48, 48, 54, 28, 0, 0, 0},
    /* $75 u */ {0, 0, 0, 0, 0, 204, 204, 204, 204, 204, 204, 204, 118, 0, 0, 0},
    /* $76 v */ {0, 0, 0, 0, 0, 102, 102, 102, 102, 102, 102, 60, 24, 0, 0, 0},
    /* $77 w */ {0, 0, 0, 0, 0, 198, 198, 198, 214, 214, 254, 108, 108, 0, 0, 0},
    /* $78 x */ {0, 0, 0, 0, 0, 198, 198, 108, 56, 56, 108, 198, 198, 0, 0, 0},
    /* $79 y  */ {0, 0, 0, 0, 0, 198, 198, 198, 198, 198, 198, 126, 6, 12, 248, 0},
    /* $7A z */ {0, 0, 0, 0, 0, 254, 198, 204, 24, 48, 102, 198, 254, 0, 0, 0},
    /* $7B { */ {0, 14, 24, 24, 24, 24, 24, 112, 112, 24, 24, 24, 24, 24, 14, 0},
    /* $7C | */ {0, 0, 24, 24, 24, 24, 24, 0, 24, 24, 24, 24, 24, 0, 0, 0},
    /* $7D } */ {0, 112, 24, 24, 24, 24, 24, 14, 14, 24, 24, 24, 24, 24, 112, 0},
    /* $7E ~ */ {0, 0, 118, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    /* $7F   */ {0, 0, 0, 0, 16, 56, 108, 198, 198, 198, 198, 254, 0, 0, 0, 0},         // Домик непечатаемый
    /* $80 А */ {0, 0, 16, 56, 108, 198, 198, 198, 254, 198, 198, 198, 198, 0, 0, 0},
    /* $81 Б */ {0, 0, 254, 102, 98, 96, 124, 102, 102, 102, 102, 102, 252, 0, 0, 0},
    /* $82 В */ {0, 0, 252, 102, 102, 102, 124, 102, 102, 102, 102, 102, 252, 0, 0, 0},
    /* $83 Г */ {0, 0, 254, 102, 98, 96, 96, 96, 96, 96, 96, 96, 240, 0, 0, 0},
    /* $84 Д */ {0, 0, 62, 102, 102, 102, 102, 102, 102, 102, 102, 102, 255, 195, 195, 0},
    /* $85 Е */ {0, 0, 254, 102, 102, 98, 104, 120, 104, 98, 102, 102, 254, 0, 0, 0},
    /* $86 Ж */ {0, 0, 214, 214, 214, 124, 56, 124, 214, 214, 214, 214, 214, 0, 0, 0},
    /* $87 З */ {0, 0, 124, 198, 6, 6, 6, 60, 6, 6, 6, 198, 124, 0, 0, 0},
    /* $88 И */ {0, 0, 198, 198, 206, 222, 254, 246, 230, 198, 198, 198, 198, 0, 0, 0},
    /* $89 Й */ {56, 56, 198, 198, 206, 222, 254, 246, 230, 198, 198, 198, 198, 0, 0, 0},
    /* $8A К */ {0, 0, 230, 102, 108, 108, 120, 108, 108, 102, 102, 102, 230, 0, 0, 0},
    /* $8B Л */ {0, 0, 62, 102, 102, 102, 102, 102, 102, 102, 102, 102, 230, 0, 0, 0},
    /* $8C М */ {0, 0, 198, 238, 254, 254, 214, 198, 198, 198, 198, 198, 198, 0, 0, 0},
    /* $8D Н */ {0, 0, 198, 198, 198, 198, 254, 198, 198, 198, 198, 198, 198, 0, 0, 0},
    /* $8E О */ {0, 0, 124, 198, 198, 198, 198, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $8F П */ {0, 0, 254, 198, 198, 198, 198, 198, 198, 198, 198, 198, 198, 0, 0, 0},
    /* $90 Р */ {0, 0, 252, 102, 102, 102, 102, 102, 124, 96, 96, 96, 240, 0, 0, 0},
    /* $91 С */ {0, 0, 124, 198, 198, 192, 192, 192, 192, 198, 198, 198, 124, 0, 0, 0},
    /* $92 Т */ {0, 0, 126, 126, 90, 24, 24, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $93 У */ {0, 0, 198, 198, 198, 198, 198, 126, 6, 6, 6, 198, 124, 0, 0, 0},
    /* $94 Ф */ {0, 0, 24, 126, 219, 219, 219, 219, 219, 219, 219, 126, 24, 0, 0, 0},
    /* $95 Х */ {0, 0, 198, 198, 198, 108, 56, 56, 56, 108, 198, 198, 198, 0, 0, 0},
    /* $96 Ц */ {0, 0, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 254, 6, 6, 0},
    /* $97 Ч */ {0, 0, 198, 198, 198, 198, 198, 198, 126, 6, 6, 6, 6, 0, 0, 0},
    /* $98 Ш */ {0, 0, 214, 214, 214, 214, 214, 214, 214, 214, 214, 214, 254, 0, 0, 0},
    /* $99 Щ */ {0, 0, 214, 214, 214, 214, 214, 214, 214, 214, 214, 214, 254, 3, 3, 0},
    /* $9A Ъ */ {0, 0, 248, 240, 176, 48, 60, 54, 54, 54, 54, 54, 124, 0, 0, 0},
    /* $9B Ы */ {0, 0, 198, 198, 198, 198, 246, 222, 222, 222, 222, 222, 246, 0, 0, 0},
    /* $9C Ь */ {0, 0, 240, 96, 96, 96, 124, 102, 102, 102, 102, 102, 252, 0, 0, 0},
    /* $9D Э */ {0, 0, 120, 204, 134, 134, 38, 62, 38, 134, 134, 204, 120, 0, 0, 0},
    /* $9E Ю */ {0, 0, 156, 182, 182, 182, 182, 246, 182, 182, 182, 182, 156, 0, 0, 0},
    /* $9F Я */ {0, 0, 126, 204, 204, 204, 204, 124, 108, 204, 204, 206, 206, 0, 0, 0},
    /* $A0 а */ {0, 0, 0, 0, 0, 120, 204, 12, 124, 204, 204, 204, 118, 0, 0, 0},
    /* $A1 б */ {0, 0, 0, 28, 48, 96, 124, 102, 102, 102, 102, 102, 60, 0, 0, 0},
    /* $A2 в */ {0, 0, 0, 0, 0, 252, 102, 102, 124, 102, 102, 102, 252, 0, 0, 0},
    /* $A3 г */ {0, 0, 0, 0, 0, 254, 98, 96, 96, 96, 96, 96, 240, 0, 0, 0},
    /* $A4 д */ {0, 0, 0, 0, 0, 62, 102, 102, 102, 102, 102, 102, 255, 195, 195, 0},
    /* $A5 е */ {0, 0, 0, 0, 0, 124, 198, 198, 254, 192, 192, 198, 124, 0, 0, 0},
    /* $A6 ж */ {0, 0, 0, 0, 0, 214, 214, 214, 124, 124, 214, 214, 214, 0, 0, 0},
    /* $A7 з */ {0, 0, 0, 0, 0, 60, 102, 102, 12, 6, 102, 102, 60, 0, 0, 0},
    /* $A8 и */ {0, 0, 0, 0, 0, 198, 206, 222, 254, 246, 230, 198, 198, 0, 0, 0},
    /* $A9 й */ {0, 0, 56, 56, 0, 198, 206, 222, 254, 246, 230, 198, 198, 0, 0, 0},
    /* $AA к */ {0, 0, 0, 0, 0, 230, 102, 108, 120, 108, 102, 102, 230, 0, 0, 0},
    /* $AB л */ {0, 0, 0, 0, 0, 62, 102, 102, 102, 102, 102, 102, 230, 0, 0, 0},
    /* $AC м */ {0, 0, 0, 0, 0, 198, 238, 254, 254, 214, 198, 198, 198, 0, 0, 0},
    /* $AD н */ {0, 0, 0, 0, 0, 198, 198, 198, 254, 198, 198, 198, 198, 0, 0, 0},
    /* $AE о */ {0, 0, 0, 0, 0, 124, 198, 198, 198, 198, 198, 198, 124, 0, 0, 0},
    /* $AF п */ {0, 0, 0, 0, 0, 254, 198, 198, 198, 198, 198, 198, 198, 0, 0, 0},
    // Псевдографика $B0-$DF
    /* $B0 */ {68, 17, 68, 17, 68, 17, 68, 17, 68, 17, 68, 17, 68, 17, 68, 17},
    /* $B1 */ {170, 85, 170, 85, 170, 85, 170, 85, 170, 85, 170, 85, 170, 85, 170, 85},
    /* $B2 */ {119, 221, 119, 221, 119, 221, 119, 221, 119, 221, 119, 221, 119, 221, 119, 221},
    /* $B3 */ {24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24},
    /* $B4 */ {24, 24, 24, 24, 24, 24, 24, 24, 248, 24, 24, 24, 24, 24, 24, 24},
    /* $B5 */ {24, 24, 24, 24, 24, 24, 248, 24, 248, 24, 24, 24, 24, 24, 24, 24},
    /* $B6 */ {54, 54, 54, 54, 54, 54, 54, 54, 246, 54, 54, 54, 54, 54, 54, 54},
    /* $B7 */ {0, 0, 0, 0, 0, 0, 0, 0, 254, 54, 54, 54, 54, 54, 54, 54},
    /* $B8 */ {0, 0, 0, 0, 0, 0, 248, 24, 248, 24, 24, 24, 24, 24, 24, 24},
    /* $B9 */ {54, 54, 54, 54, 54, 54, 246, 6, 246, 54, 54, 54, 54, 54, 54, 54},
    /* $BA */ {54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54, 54},
    /* $BB */ {0, 0, 0, 0, 0, 0, 254, 6, 246, 54, 54, 54, 54, 54, 54, 54},
    /* $BC */ {54, 54, 54, 54, 54, 54, 246, 6, 254, 0, 0, 0, 0, 0, 0, 0},
    /* $BD */ {54, 54, 54, 54, 54, 54, 54, 54, 254, 0, 0, 0, 0, 0, 0, 0},
    /* $BE */ {24, 24, 24, 24, 24, 24, 248, 24, 248, 0, 0, 0, 0, 0, 0, 0},
    /* $BF */ {0, 0, 0, 0, 0, 0, 0, 0, 248, 24, 24, 24, 24, 24, 24, 24},
    /* $C0 */ {24, 24, 24, 24, 24, 24, 24, 24, 31, 0, 0, 0, 0, 0, 0, 0},
    /* $C1 */ {24, 24, 24, 24, 24, 24, 24, 24, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $C2 */ {0, 0, 0, 0, 0, 0, 0, 0, 255, 24, 24, 24, 24, 24, 24, 24},
    /* $C3 */ {24, 24, 24, 24, 24, 24, 24, 24, 31, 24, 24, 24, 24, 24, 24, 24},
    /* $C4 */ {0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $C5 */ {24, 24, 24, 24, 24, 24, 24, 24, 255, 24, 24, 24, 24, 24, 24, 24},
    /* $C6 */ {24, 24, 24, 24, 24, 24, 31, 24, 31, 24, 24, 24, 24, 24, 24, 24},
    /* $C7 */ {54, 54, 54, 54, 54, 54, 54, 54, 55, 54, 54, 54, 54, 54, 54, 54},
    /* $C8 */ {54, 54, 54, 54, 54, 54, 55, 48, 63, 0, 0, 0, 0, 0, 0, 0},
    /* $C9 */ {0, 0, 0, 0, 0, 0, 63, 48, 55, 54, 54, 54, 54, 54, 54, 54},
    /* $CA */ {54, 54, 54, 54, 54, 54, 247, 0, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $CB */ {0, 0, 0, 0, 0, 0, 255, 0, 247, 54, 54, 54, 54, 54, 54, 54},
    /* $CC */ {54, 54, 54, 54, 54, 54, 55, 48, 55, 54, 54, 54, 54, 54, 54, 54},
    /* $CD */ {0, 0, 0, 0, 0, 0, 255, 0, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $CE */ {54, 54, 54, 54, 54, 54, 247, 0, 247, 54, 54, 54, 54, 54, 54, 54},
    /* $CF */ {24, 24, 24, 24, 24, 24, 255, 0, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $D0 */ {54, 54, 54, 54, 54, 54, 54, 54, 255, 0, 0, 0, 0, 0, 0, 0},
    /* $D1 */ {0, 0, 0, 0, 0, 0, 255, 0, 255, 24, 24, 24, 24, 24, 24, 24},
    /* $D2 */ {0, 0, 0, 0, 0, 0, 0, 0, 255, 54, 54, 54, 54, 54, 54, 54},
    /* $D3 */ {54, 54, 54, 54, 54, 54, 54, 54, 63, 0, 0, 0, 0, 0, 0, 0},
    /* $D4 */ {24, 24, 24, 24, 24, 24, 31, 24, 31, 0, 0, 0, 0, 0, 0, 0},
    /* $D5 */ {0, 0, 0, 0, 0, 0, 31, 24, 31, 24, 24, 24, 24, 24, 24, 24},
    /* $D6 */ {0, 0, 0, 0, 0, 0, 0, 0, 63, 54, 54, 54, 54, 54, 54, 54},
    /* $D7 */ {54, 54, 54, 54, 54, 54, 54, 54, 255, 54, 54, 54, 54, 54, 54, 54},
    /* $D8 */ {24, 24, 24, 24, 24, 24, 255, 24, 255, 24, 24, 24, 24, 24, 24, 24},
    /* $D9 */ {24, 24, 24, 24, 24, 24, 24, 24, 248, 0, 0, 0, 0, 0, 0, 0},
    /* $DA */ {0, 0, 0, 0, 0, 0, 0, 0, 31, 24, 24, 24, 24, 24, 24, 24},
    /* $DB */ {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
    /* $DC */ {0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255},
    /* $DD */ {240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240},
    /* $DE */ {15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
    /* $DF */ {255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0},

    // Русский алфавит - второй том
    /* $E0 р */ {0, 0, 0, 0, 0, 220, 102, 102, 102, 102, 102, 124, 96, 96, 240, 0},
    /* $E1 с */ {0, 0, 0, 0, 0, 124, 198, 198, 192, 192, 198, 198, 124, 0, 0, 0},
    /* $E2 т */ {0, 0, 0, 0, 0, 126, 90, 24, 24, 24, 24, 24, 60, 0, 0, 0},
    /* $E3 у */ {0, 0, 0, 0, 0, 198, 198, 198, 198, 198, 198, 126, 6, 12, 248, 0},
    /* $E4 ф */ {0, 0, 0, 0, 0, 24, 126, 219, 219, 219, 219, 219, 126, 24, 24, 0},
    /* $E5 х */ {0, 0, 0, 0, 0, 198, 198, 108, 56, 56, 108, 198, 198, 0, 0, 0},
    /* $E6 ц */ {0, 0, 0, 0, 0, 204, 204, 204, 204, 204, 204, 204, 254, 6, 6, 0},
    /* $E7 ч */ {0, 0, 0, 0, 0, 198, 198, 198, 198, 126, 6, 6, 6, 0, 0, 0},
    /* $E8 ш */ {0, 0, 0, 0, 0, 214, 214, 214, 214, 214, 214, 214, 254, 0, 0, 0},
    /* $E9 щ */ {0, 0, 0, 0, 0, 214, 214, 214, 214, 214, 214, 214, 254, 3, 3, 0},
    /* $EA ъ */ {0, 0, 0, 0, 0, 248, 176, 60, 54, 54, 54, 54, 124, 0, 0, 0},
    /* $EB ы */ {0, 0, 0, 0, 0, 198, 198, 246, 222, 222, 222, 222, 246, 0, 0, 0},
    /* $EC ь */ {0, 0, 0, 0, 0, 240, 96, 96, 124, 102, 102, 102, 252, 0, 0, 0},
    /* $ED э */ {0, 0, 0, 0, 0, 60, 102, 6, 30, 6, 102, 102, 60, 0, 0, 0},
    /* $EE ю */ {0, 0, 0, 0, 0, 156, 182, 182, 246, 182, 182, 182, 156, 0, 0, 0},
    /* $EF я */ {0, 0, 0, 0, 0, 126, 204, 204, 204, 124, 108, 204, 206, 0, 0, 0},

    // Математические спецсимволы
    /* $F0 === */ {0, 0, 0, 0, 254, 0, 0, 254, 0, 0, 254, 0, 0, 0, 0, 0},
    /* $F1 +/- */ {0, 0, 0, 0, 24, 24, 126, 24, 24, 0, 0, 255, 0, 0, 0, 0},
    /* $F2 >=  */ {0, 0, 0, 48, 24, 12, 6, 12, 24, 48, 0, 126, 0, 0, 0, 0},
    /* $F3 <=  */ {0, 0, 0, 12, 24, 48, 96, 48, 24, 12, 0, 126, 0, 0, 0, 0},
    /* $F4 It  */ {0, 0, 0, 14, 27, 27, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24},   // Верхний интеграл
    /* $F5 Id  */ {24, 24, 24, 24, 24, 24, 24, 24, 24, 216, 216, 112, 0, 0, 0, 0}, // Нижний
    /* $F6 ./. */ {0, 0, 0, 0, 24, 24, 0, 126, 0, 24, 24, 0, 0, 0, 0, 0},          // Деление
    /* $F7 ~~~ */ {0, 0, 0, 0, 0, 118, 220, 0, 118, 220, 0, 0, 0, 0, 0, 0},        // Не равно
    /* $F8 o   */ {0, 56, 108, 108, 108, 56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},        // Градус
    /* $F9 .   */ {0, 0, 0, 0, 0, 0, 0, 24, 24, 0, 0, 0, 0, 0, 0, 0},              // Крупная точка
    /* $FA .   */ {0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0},               // Маленькая точка
    /* $FB \/~ */ {0, 15, 12, 12, 12, 12, 12, 236, 108, 60, 28, 12, 0, 0, 0, 0},   // Корневище
    /* $FC n   */ {0, 0, 216, 108, 108, 108, 108, 108, 0, 0, 0, 0, 0, 0, 0, 0},    // Номер
    /* $FD 2   */ {0, 0, 112, 216, 48, 96, 200, 248, 0, 0, 0, 0, 0, 0, 0, 0},      // Квадрат
    /* $FE |   */ {0, 0, 0, 0, 60, 60, 60, 60, 60, 60, 60, 60, 0, 0, 0, 0},        // Прямоугольник
    /* $FF     */ {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}                 // Пустая символга
};

static const int dospalette[256] = {
  0x000000, 0x0000aa, 0x00aa00, 0x00aaaa, 0xaa0000, 0xaa00aa, 0xaa5500, 0xaaaaaa, // 0
  0x555555, 0x5555ff, 0x55ff55, 0x55ffff, 0xff5555, 0xff55ff, 0xffff55, 0xffffff, // 8
  0x000000, 0x141414, 0x202020, 0x2c2c2c, 0x383838, 0x454545, 0x515151, 0x616161, // 10
  0x717171, 0x828282, 0x929292, 0xa2a2a2, 0xb6b6b6, 0xcbcbcb, 0xe3e3e3, 0xffffff, // 18
  0x0000ff, 0x4100ff, 0x7d00ff, 0xbe00ff, 0xff00ff, 0xff00be, 0xff007d, 0xff0041, // 20
  0xff0000, 0xff4100, 0xff7d00, 0xffbe00, 0xffff00, 0xbeff00, 0x7dff00, 0x41ff00, // 28
  0x00ff00, 0x00ff41, 0x00ff7d, 0x00ffbe, 0x00ffff, 0x00beff, 0x007dff, 0x0041ff, // 30
  0x7d7dff, 0x9e7dff, 0xbe7dff, 0xdf7dff, 0xff7dff, 0xff7ddf, 0xff7dbe, 0xff7d9e, // 38
  0xff7d7d, 0xff9e7d, 0xffbe7d, 0xffdf7d, 0xffff7d, 0xdfff7d, 0xbeff7d, 0x9eff7d, // 40
  0x7dff7d, 0x7dff9e, 0x7dffbe, 0x7dffdf, 0x7dffff, 0x7ddfff, 0x7dbeff, 0x7d9eff, // 48
  0xb6b6ff, 0xc7b6ff, 0xdbb6ff, 0xebb6ff, 0xffb6ff, 0xffb6eb, 0xffb6db, 0xffb6c7, // 50
  0xffb6b6, 0xffc7b6, 0xffdbb6, 0xffebb6, 0xffffb6, 0xebffb6, 0xdbffb6, 0xc7ffb6, // 58
  0xb6ffb6, 0xb6ffc7, 0xb6ffdb, 0xb6ffeb, 0xb6ffff, 0xb6ebff, 0xb6dbff, 0xb6c7ff, // 60
  0x000071, 0x1c0071, 0x380071, 0x550071, 0x710071, 0x710055, 0x710038, 0x71001c, // 68
  0x710000, 0x711c00, 0x713800, 0x715500, 0x717100, 0x557100, 0x387100, 0x1c7100, // 70
  0x007100, 0x00711c, 0x007138, 0x007155, 0x007171, 0x005571, 0x003871, 0x001c71, // 78
  0x383871, 0x453871, 0x553871, 0x613871, 0x713871, 0x713861, 0x713855, 0x713845, // 80
  0x713838, 0x714538, 0x715538, 0x716138, 0x717138, 0x617138, 0x557138, 0x457138, // 88
  0x387138, 0x387145, 0x387155, 0x387161, 0x387171, 0x386171, 0x385571, 0x384571, // 90
  0x515171, 0x595171, 0x615171, 0x695171, 0x715171, 0x715169, 0x715161, 0x715159, // 98
  0x715151, 0x715951, 0x716151, 0x716951, 0x717151, 0x697151, 0x617151, 0x597151, // A0
  0x517151, 0x517159, 0x517161, 0x517169, 0x517171, 0x516971, 0x516171, 0x515971, // A8
  0x000041, 0x100041, 0x200041, 0x300041, 0x410041, 0x410030, 0x410020, 0x410010, // B0
  0x410000, 0x411000, 0x412000, 0x413000, 0x414100, 0x304100, 0x204100, 0x104100, // B8
  0x004100, 0x004110, 0x004120, 0x004130, 0x004141, 0x003041, 0x002041, 0x001041, // C0
  0x202041, 0x282041, 0x302041, 0x382041, 0x412041, 0x412038, 0x412030, 0x412028, // C8
  0x412020, 0x412820, 0x413020, 0x413820, 0x414120, 0x384120, 0x304120, 0x284120, // D0
  0x204120, 0x204128, 0x204130, 0x204138, 0x204141, 0x203841, 0x203041, 0x202841, // D8
  0x2c2c41, 0x302c41, 0x342c41, 0x3c2c41, 0x412c41, 0x412c3c, 0x412c34, 0x412c30, // E0
  0x412c2c, 0x41302c, 0x41342c, 0x413c2c, 0x41412c, 0x3c412c, 0x34412c, 0x30412c, // E8
  0x2c412c, 0x2c4130, 0x2c4134, 0x2c413c, 0x2c4141, 0x2c3c41, 0x2c3441, 0x2c3041, // F0
  0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000  // F8
};

#endif
