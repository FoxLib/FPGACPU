#include <SDL.h>

enum Reg16 {
    BC = 0,
    DE = 1,
    HL = 2,
    AF = 3,
    SP = 4
};

enum Reg8 {

    regC = 0,
    regB = 1,
    regE = 2,
    regD = 3,
    regL = 4,
    regH = 5,
    regF = 6,
    regA = 7
};

class CPU {
protected:

    uint8_t     mem[65536];

    uint8_t     a, f, a_, f_;
    uint8_t     b, c, b_, c_;
    uint8_t     d, e, d_, e_;
    uint8_t     h, l, h_, l_;
    uint16_t    sp;
    uint16_t    pc;
    uint8_t     halt, iff0, iff1, im;
    uint32_t    cycles;

    // Дизассемблер
    int         width, height, color_fore, color_back;
    int         ds_ad;
    int         enable_halt;
    int         ds_dumpaddr;
    int         ds_cursor;
    int         ds_start;
    int         bp_count;
    int         ds_size;
    int         ds_match_row;
    char        ds_rowdis[64];
    char        ds_operand[64];
    char        ds_opcode[64];
    int         bp_rows[1024];

public:

    CPU();
    void        load(const char* fn, int addr);
    void        dump();
    void        dump(uint16_t addr);
    void        write(uint16_t addr, uint8_t b);
    uint8_t     read(uint16_t addr);
    uint16_t    read_word(uint16_t addr);
    void        write_word(uint16_t addr, uint16_t value);
    uint8_t     fetch();
    uint16_t    fetchw();
    int         fetch_sign();
    void        put_bc(uint16_t v);
    void        put_de(uint16_t v);
    void        put_hl(uint16_t v);
    uint16_t    bc();
    uint16_t    de();
    uint16_t    hl();

    uint16_t    alu_adc_hl(uint16_t op);
    uint8_t     alu_add(uint8_t op1, uint8_t op2);
    uint8_t     alu_sub(uint8_t op1, uint8_t op2);
    uint8_t     alu_adc(uint8_t op1, uint8_t op2);
    uint8_t     alu_sbc(uint8_t op1, uint8_t op2);
    uint8_t     alu_and(uint8_t op1, uint8_t op2);
    uint8_t     alu_xor(uint8_t op1, uint8_t op2);
    uint8_t     alu_or (uint8_t op1, uint8_t op2);
    uint8_t     alu_rlc(uint8_t op);
    uint8_t     alu_rrc(uint8_t op);
    uint8_t     alu_rl (uint8_t op);
    uint8_t     alu_rr (uint8_t op);
    uint8_t     alu_daa(uint8_t op);
    uint8_t     alu_cpl(uint8_t op);
    uint8_t     alu_scf(uint8_t op);
    uint8_t     alu_ccf(uint8_t op);
    void        daa();

    void        set_sign(int v)     { f = (f & ~0x80) | (v & 0x80 ? 0x80 : 0); };
    void        set_zero(uint8_t v) { f = (f & ~0x40) | (v == 0 ? 0x40 : 0); };
    void        set_aux(int v)      { f = (f & ~0x10) | (v ? 0x10 : 0); };
    void        set_parity(uint8_t v)
    {
        v = (v & 0x0F) ^ (v >> 4);
        v = (v & 0x03) ^ (v >> 2);
        v = (v & 0x01) ^ (v >> 1) ^ 1;
        f = (f & ~0x04) | (v ? 0x04 : 0);
    };
    void        set_overflow(int v) { f = (f & ~0x04) | (v ? 0x04 : 0); };
    void        set_carry(int v)    { f = (f & ~0x01) | (v ? 0x01 : 0); };
    void        step();

    // Дизассемблер
    void        cls();
    void        color(int fore, int back);
    void        print_char(int x, int y, unsigned char ch);
    void        print(int x, int y, const char* s);
    int         ds_fetch_byte();
    int         ds_fetch_word();
    int         ds_fetch_rel();
    int         disasm_line(int addr);
    void        disasm_repaint();
};
