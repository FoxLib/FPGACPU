#include "gigatron.h"

int main(int argc, char* argv[]) {

    Gigatron g(640, 480, "Gigatron emulator");

    g.stop();
    g.list();
    g.start();
    return 0;
}
