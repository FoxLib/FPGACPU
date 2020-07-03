#include <stdio.h>
#include "ui.h"
#include "cpu.h"

// Частота процессора 1 МГц
#define CPU_FREQUENCY_KHZ 1000

int main(int argc, char* argv[]) {

    startup("EasyCPU", 1280, 800);

    CPU cpu;
    cpu.load(argc, argv);

    int stop = 1;
    int debubber_on = 1;

    cpu.debug();

    while (int evt = mainloop()) {

        if (evt & KEYDOWN) { cpu.sendkey(kbcode(), 1); }
        if (evt & KEYUP)   { cpu.sendkey(kbcode(), 0); }

        // Машина остановлена - отладка
        if (stop) {

            if (evt & KEYDOWN) {

                /* F7 Выполнить шаг */
                if (kbcode() == 65) {

                    if (debubber_on) {
                        cpu.debugstep();
                    } else {
                        cpu.step();
                        cpu.setdsip();
                        cpu.screen_update();
                    }
                }
                /* F4 Обмен экрана */
                else if (kbcode() == 62) {

                    if (debubber_on) {
                        debubber_on = 0;
                        cpu.screen_update();
                    } else {
                        debubber_on = 1;
                        cpu.debug();
                    }
                }
                /* F9 Запуск|Останов */
                else if (kbcode() == 67) {

                    debubber_on = 0;
                    cpu.screen_update();
                    stop = 0;
                }

                //printf("%d|", kbcode());
            }
        }
        // Выполниить несколько инструкции [скорость 50 КГц]
        else {

            for (int i = 0; i < CPU_FREQUENCY_KHZ*(1000/50); i++) {
                if (cpu.step()) {
                    stop = debubber_on = 1;
                    cpu.setdsip(); cpu.debug();
                    break;
                }
            }

            // Остановка исполнения
            if ((evt & KEYDOWN) && (kbcode() == 67) && debubber_on == 0) {

                stop = debubber_on = 1;
                cpu.setdsip(); cpu.debug();
            }
        }
    }

    return 0;
}
