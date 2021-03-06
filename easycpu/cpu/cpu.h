#include "ui.h"

#define byte    unsigned char
#define word    unsigned short
#define dword   unsigned int

class CPU {

protected:

    byte    mem[1024*1024];
    word    ip;
    word    opcode;
    word    acc;
    word    regs[16];
    byte    cf, zf, intf;

    // Keyboard
    int     keyb_code_in;
    byte    keyb_cntr;

    // Отладка
    word    up, ds;

public:

    CPU();
    void    fatal(const char* err);
    int     load(int argc, char* argv[]);
    void    screen_update();
    void    debug();
    void    debugstep();
    void    setdsip();
    void    sendkey(int xt, int press);
    void    send_irq();
    int     is_intf();
    int     step();
    byte    fetch_byte();
    word    fetch_word();
    int     fetch_signed();
    void    write(word addr, byte data);
    void    update_char(int addr);
};
