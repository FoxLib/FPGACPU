#include "gigatron.h"

// Обработчик кадра
uint WindowTimer(uint interval, void *param) {

    SDL_Event     event;
    SDL_UserEvent userevent;

    /* Создать новый Event */
    userevent.type  = SDL_USEREVENT;
    userevent.code  = 0;
    userevent.data1 = NULL;
    userevent.data2 = NULL;

    event.type = SDL_USEREVENT;
    event.user = userevent;

    SDL_PushEvent(&event);
    return (interval);
}

// Конструктор
Gigatron::Gigatron(int w, int h, const char* caption) {

    width  = w;
    height = h;

    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);
    SDL_EnableUNICODE(1);

    sdl_screen = SDL_SetVideoMode(w, h, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
    SDL_WM_SetCaption(caption, 0);

    // Инициализация процессора
    procstart();
    vga_init();
    audio_init();

    require_stop = 0;
    press_shift  = 0;
    press_ctrl   = 0;
    press_alt    = 0;
    
    SDL_AddTimer(10, WindowTimer, NULL);
}

// Эмулятор 1 тика процессора
void Gigatron::all_tick() {

    tick();
    vga_tick();
    audio_tick();
}

// Обработчик событий с окна
void Gigatron::start() {

    int keyid;

    while (1) {

        while (SDL_PollEvent(& event)) {

            switch (event.type) {

                // Если нажато на крестик, то приложение будет закрыто
                case SDL_QUIT:
                    return;

                case SDL_MOUSEMOTION:
                    break;

                // Нажата какая-то клавиша
                case SDL_KEYDOWN:

                    if (started)
                         gamepad_press(event);
                    else debugger_press(event);

                    break;

                // Отпущена клавиша
                case SDL_KEYUP:

                    if (started) gamepad_up(event);
                    break;

                // Вызывается по таймеру
                case SDL_USEREVENT:

                    if (started) {

                        for (int i = 0; i < 62500; i++) {

                            all_tick();

                            // BREAK
                            if (started == 0) { require_stop = 1; break; }
                        }
                    }

                    // Запрошен останов процессора
                    if (require_stop) {

                        require_stop  = 0;
                        disasm_cursor = pc;
                        disasm_start  = pc;
                        stop();
                        list();
                    }

                    SDL_Flip(sdl_screen);
                    break;
            }
        }

        SDL_Delay(1);
    }
}

void Gigatron::pset(int x, int y, uint32_t color) {

    if (x >= 0 && y >= 0 && x < width && y < height) {
        ( (Uint32*)sdl_screen->pixels )[ x + width*y ] = color;
    }
}
