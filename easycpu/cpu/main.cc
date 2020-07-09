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

        // Машина остановлена - отладка
        if (stop) {

            if (evt & KEYDOWN) {

                /* F7 Выполнить шаг */
                if (kbcode() == 0x83) {

                    if (debubber_on) {
                        cpu.debugstep();
                    } else {
                        cpu.step();
                        cpu.setdsip();
                        cpu.screen_update();
                    }
                }
                /* F4 Обмен экрана */
                else if (kbcode() == 0x0C) {

                    if (debubber_on) {
                        debubber_on = 0;
                        cpu.screen_update();
                    } else {
                        debubber_on = 1;
                        cpu.debug();
                    }
                }

            }
            /* F9 Запуск|Останов */
            else if ((evt & KEYUP) && kbcode() == 0x01) {

                debubber_on = 0;
                cpu.screen_update();
                stop = 0;
            }
        }
        // Выполниить несколько инструкции [скорость 50 КГц]
        else {

            // Отслеживание нажатия в реальном времени
            if (cpu.is_intf() && (evt & KEYDOWN)) { cpu.sendkey(kbcode(), 1); }
            if (cpu.is_intf() && (evt & KEYUP))  { cpu.sendkey(kbcode(), 0); }

            cpu.send_irq();

            for (int i = 0; i < CPU_FREQUENCY_KHZ*(1000/50); i++) {

                if (cpu.step()) {
                    stop = debubber_on = 1;
                    cpu.setdsip(); cpu.debug();
                    break;
                }
            }

            // Остановка исполнения
            if ((evt & KEYUP) && (kbcode() == 0x01) && debubber_on == 0) {

                stop = debubber_on = 1;
                cpu.setdsip(); cpu.debug();
            }
        }
    }

    return 0;
}
