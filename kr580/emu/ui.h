#include <SDL.h>

enum EVENTYPES {
    FPS     = 1,
    KEYDOWN = 2,
    KEYUP   = 4
};

uint windowtimer(uint interval, void *param);
int  get_key(SDL_Event event);
void startup(const char* name, int w, int h);
void pset(int x, int y, int cl);
void psetmini(int x, int y, int cl);
int  mainloop();
