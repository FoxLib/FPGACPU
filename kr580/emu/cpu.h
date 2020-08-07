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

    uint8_t     a, f;
    uint8_t     b, c;
    uint8_t     d, e;
    uint8_t     h, l;
    uint16_t    sp;
    uint16_t    pc;
    uint8_t     mem[65536];

public:

    CPU();
    void        load(const char* fn, int addr);
    void        dump();
    void        dump(uint16_t addr);
    void        write(uint16_t addr, uint8_t b);
    uint8_t     read(uint16_t addr);
    uint8_t     fetch();
    uint16_t    fetch_word();
    void        putw(int reg16, uint16_t value);
    uint16_t    bc();
    uint16_t    de();
    uint16_t    hl();

    uint8_t     alu_add(uint8_t op1, uint8_t op2);
    uint8_t     alu_sub(uint8_t op1, uint8_t op2);
    uint8_t     alu_adc(uint8_t op1, uint8_t op2);
    uint8_t     alu_sbc(uint8_t op1, uint8_t op2);
    uint8_t     alu_and(uint8_t op1, uint8_t op2);
    uint8_t     alu_xor(uint8_t op1, uint8_t op2);
    uint8_t     alu_or (uint8_t op1, uint8_t op2);

    void        set_sign(int v)   { f = (f & ~0x80) | (v ? 0x80 : 0); };
    void        set_zero(int v)   { f = (f & ~0x40) | (v == 0 ? 0x40 : 0); };
    void        set_aux(int v)    { f = (f & ~0x10) | (v ? 0x10 : 0); };
    void        set_parity(uint8_t v)
    {
        v = (v & 0x0F) ^ (v >> 4);
        v = (v & 0x03) ^ (v >> 2);
        v = (v & 0x01) ^ (v >> 1) ^ 1;
        f = (f & ~0x04) | (v ? 0x04 : 0);
    };
    void        set_carry(int v)  { f = (f & ~0x01) | (v ? 0x01 : 0); };
    void        step();
};
