#include <stdlib.h>
#include <stdio.h>

#include "ui.h"
#include "cpu.h"

CPU::CPU() {

    a = 0x00; f = 0x00;
    b = 0x00; c = 0x00;
    d = 0x00; e = 0x00;
    h = 0x00; l = 0x00;

    pc = 0x0000;
    sp = 0x0000;
}

void CPU::load(const char* fn, int addr) {

    FILE* f = fopen(fn, "rb");
    if (f) {

        fseek(f, 0, SEEK_END);
        int fsize = ftell(f);
        fseek(f, 0, SEEK_SET);
        fread(mem + addr, 1, fsize, f);
        fclose(f);

    } else {

        printf("Не могу загрузить файл %s\n", fn);
        exit(1);
    }
}

void CPU::dump() {
    printf("BC: %04X   DE: %04X    HL: %04X    AF: %04X\n", b*256+c, d*256+e, h*256+l, a*256+f);
    printf("PC: %04X   SP: %04X\n", pc, sp);
}

void CPU::dump(uint16_t addr) {

    for (int i = 0; i < 8; i++) {
        printf("%04X: ", addr);
        for (int j = 0; j < 16; j++) {
            printf("%02X ", mem[addr++]);
        }
        printf("\n");
    }
    dump();
}

void CPU::write(uint16_t addr, uint8_t b) {

    mem[addr] = b;

    // Пиксельные данные
    if (addr >= 0x4000 && addr < 0x5800) {
    }

    // Знакоместа
    if (addr >= 0x5800 && addr < 0x5B00) {
    }
}

uint8_t CPU::read(uint16_t addr) {
    return mem[addr];
}

uint8_t CPU::fetch() {
    return mem[pc++];
}

uint16_t CPU::fetch_word() {

    uint8_t l = fetch();
    uint8_t h = fetch();
    return (h<<8) | l;
}

void CPU::putw(int reg16, uint16_t value) {

    switch (reg16) {

        case BC: b = (value & 0xFF00) >> 8; c = value & 0xFF; break;
        case DE: d = (value & 0xFF00) >> 8; e = value & 0xFF; break;
        case HL: h = (value & 0xFF00) >> 8; l = value & 0xFF; break;
        case AF: a = (value & 0xFF00) >> 8; f = value & 0xFF; break;
        case SP: sp = value; break;
    }
}

uint16_t CPU::bc() { return b*256 + c; }
uint16_t CPU::de() { return d*256 + e; }
uint16_t CPU::hl() { return h*256 + l; }

uint8_t CPU::alu_add(uint8_t op1, uint8_t op2) {

    int r = op1 + op2;

    set_sign    (r & 0x80);
    set_zero    (r & 0xFF);
    set_aux     ((op1&15) + (op2&15) >= 0x10);
    set_parity  (r);
    set_carry   (r & 0x100);

    return r & 0xff;
}

void CPU::step() {

    uint16_t    t16;
    uint8_t     opcode = fetch();

    switch (opcode) {

        /* NOP          */ case 0x00: break;
        /* LD BC, ##    */ case 0x01: putw(BC, fetch_word()); break;
        /* LD (BC), A   */ case 0x02: write(bc(), a); break;
        /* INC BC       */ case 0x03: putw(BC, bc() + 1); break;
        /* INC B        */ case 0x04: b = alu_add(b, 1); break;
        /* DEC B        */ case 0x05: break;
        /* LD B, #      */ case 0x06: b = fetch(); break;
        /* RLCA         */ case 0x07: break;

        /*              */ case 0x08: break;
        /* ADD HL, BC   */ case 0x09: break;
        /* LD A, (BC)   */ case 0x0A: a = read(bc()); break;
        /* DEC BC       */ case 0x0B: putw(BC, bc() - 1); break;
        /* INC C        */ case 0x0C: c = alu_add(c, 1); break;
        /* DEC C        */ case 0x0D: break;
        /* LD C, #      */ case 0x0E: c = fetch(); break;
        /* RRCA         */ case 0x0F: break;

        /* DJNZ #       */ case 0x10: break;
        /* LD DE, ##    */ case 0x11: putw(DE, fetch_word()); break;
        /* LD (DE), A   */ case 0x12: write(de(), a); break;
        /* INC DE       */ case 0x13: putw(DE, de() + 1); break;
        /* INC D        */ case 0x14: d = alu_add(d, 1); break;
        /* DEC D        */ case 0x15: break;
        /* LD D, #      */ case 0x16: d = fetch(); break;
        /* RLA          */ case 0x17: break;

        /* JR #         */ case 0x18: break;
        /* ADD HL, DE   */ case 0x19: break;
        /* LD A, (DE)   */ case 0x1A: a = read(de()); break;
        /* DEC DE       */ case 0x1B: putw(DE, de() - 1); break;
        /* INC E        */ case 0x1C: e = alu_add(e, 1); break;
        /* DEC E        */ case 0x1D: break;
        /* LD E, #      */ case 0x1E: e = fetch(); break;
        /* RRA          */ case 0x1F: break;

        /* JR NZ, #     */ case 0x20: break;
        /* LD HL, ##    */ case 0x21: putw(HL, fetch_word()); break;
        /* LD (##), HL  */ case 0x22: break;
        /* INC HL       */ case 0x23: putw(HL, hl() + 1); break;
        /* INC H        */ case 0x24: h = alu_add(h, 1); break;
        /* DEC H        */ case 0x25: break;
        /* LD D, #      */ case 0x26: d = fetch(); break;

        /* DAA          */ case 0x27: break;
        /* JR Z, #      */ case 0x28: break;
        /* ADD HL, HL   */ case 0x29: break;
        /* LD HL, (##)  */ case 0x2A: break;
        /* DEC HL       */ case 0x2B: putw(HL, hl() - 1); break;
        /* INC L        */ case 0x2C: l = alu_add(l, 1); break;
        /* DEC L        */ case 0x2D: break;
        /* LD L, #      */ case 0x2E: l = fetch(); break;
        /* CPL          */ case 0x2F: break;

        /* JR NC, #     */ case 0x30: break;
        /* LD SP, ##    */ case 0x31: sp = fetch_word(); break;
        /* LD (##), A   */ case 0x32: break;
        /* INC SP       */ case 0x33: sp = sp + 1; break;
        /* INC (HL)     */ case 0x34: write(hl(), alu_add(read(hl()), 1)); break;
        /* DEC (HL)     */ case 0x35: break;
        /* LD (HL), #   */ case 0x36: write(hl(), fetch()); break;
        /* SCF          */ case 0x37: break;

        /* JR C, #      */ case 0x38: break;
        /* ADD HL, SP   */ case 0x39: break;
        /* LD A, (##)   */ case 0x3A: break;
        /* DEC SP       */ case 0x3B: sp = sp - 1; break;
        /* INC A        */ case 0x3C: a = alu_add(a, 1);  break;
        /* DEC A        */ case 0x3D: break;
        /* LD A, #      */ case 0x3E: a = fetch(); break;
        /* CCF          */ case 0x3F: break;
    }
}
