#include "ui.h"

int main(int argc, char* argv[]) {

    startup("КР580ВМ", 1024, 768);

    while (int evt = mainloop()) {

        // .. cpu frequency loop ...
    }

    return 0;
}
