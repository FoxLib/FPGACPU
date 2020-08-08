#include "ui.h"
#include "cpu.h"

int main(int argc, char* argv[]) {

    startup("КР580ВМ", 1024, 768);
    CPU cpu;

    if (argc > 1) { cpu.load(argv[1], 0); }

    cpu.disasm_repaint();

    while (int evt = mainloop()) {

        // .. cpu frequency loop ...
        // cpu.step();
    }

    return 0;
}
