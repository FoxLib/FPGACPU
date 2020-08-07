#include <stdlib.h>
#include <stdio.h>

#include "ui.h"
#include "cpu.h"

CPU::CPU() {

    a = 0x00; f = 0x00;
    b = 0x01; c = 0x00;
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
    printf("    76543210\n");
    printf(" F: %c%c %c %c %c\n",
        f&0x80?'s':'-',
        f&0x40?'z':'-',
        f&0x10?'a':'-',
        f&0x04?'p':'-',
        f&0x01?'c':'-');
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

int CPU::fetch_sign() {

    uint8_t x = fetch();
    return x & 0x80 ? x - 256 : x;
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

// Сложение
uint8_t CPU::alu_add(uint8_t op1, uint8_t op2) {

    int r = op1 + op2;

    set_sign    (r);
    set_zero    (r);
    set_aux     ((op1&15) + (op2&15) >= 0x10);
    set_parity  (r);
    set_carry   (r & 0x100);

    return r & 0xff;
}

// Вычитание
uint8_t CPU::alu_sub(uint8_t op1, uint8_t op2) {

    uint8_t r = op1 - op2;

    set_sign    (r);
    set_zero    (r);
    set_aux     ((op1&15) < (op2&15));
    set_parity  (r);
    set_carry   (op1 < op2);

    return r;
}

// Вращение влево
uint8_t CPU::alu_rlc(uint8_t op) {

    uint8_t r = (op<<1) | (op>>7);

    set_sign    (r);
    set_zero    (r);
    set_aux     (0);
    set_parity  (r);
    set_carry   (op & 0x80);

    return r;
}

// Вращение вправо
uint8_t CPU::alu_rrc(uint8_t op) {

    uint8_t r = (op>>1) | ((op&1)<<7);

    set_sign    (r);
    set_zero    (r);
    set_aux     (0);
    set_parity  (r);
    set_carry   (op & 1);

    return r;
}

void CPU::step() {

    uint16_t    tmp;
    uint8_t     opcode = fetch();

    switch (opcode) {

        case 0x00: /* NOP          */ break;
        case 0x01: /* LD BC, ##    */ putw(BC, fetch_word()); break;
        case 0x02: /* LD (BC), A   */ write(bc(), a); break;
        case 0x03: /* INC BC       */ putw(BC, bc() + 1); break;
        case 0x04: /* INC B        */ b = alu_add(b, 1); break;
        case 0x05: /* DEC B        */ b = alu_sub(b, 1); break;
        case 0x06: /* LD B, #      */ b = fetch(); break;
        case 0x07: /* RLCA         */ a = alu_rlc(a); break;

        case 0x08: /* ...          */ break;
        case 0x09: /* ADD HL, BC   */ break;
        case 0x0A: /* LD A, (BC)   */ a = read(bc()); break;
        case 0x0B: /* DEC BC       */ putw(BC, bc() - 1); break;
        case 0x0C: /* INC C        */ c = alu_add(c, 1); break;
        case 0x0D: /* DEC C        */ c = alu_sub(c, 1); break;
        case 0x0E: /* LD C, #      */ c = fetch(); break;
        case 0x0F: /* RRCA         */ a = alu_rrc(a);  break;

        case 0x10: /* DJNZ #       */ tmp = fetch_sign(); if (--b != 0) pc += tmp; break;
        case 0x11: /* LD DE, ##    */ putw(DE, fetch_word()); break;
        case 0x12: /* LD (DE), A   */ write(de(), a); break;
        case 0x13: /* INC DE       */ putw(DE, de() + 1); break;
        case 0x14: /* INC D        */ d = alu_add(d, 1); break;
        case 0x15: /* DEC D        */ d = alu_sub(d, 1); break;
        case 0x16: /* LD D, #      */ d = fetch(); break;
        case 0x17: /* RLA          */ break;

        case 0x18: /* JR #         */ break;
        case 0x19: /* ADD HL, DE   */ break;
        case 0x1A: /* LD A, (DE)   */ a = read(de()); break;
        case 0x1B: /* DEC DE       */ putw(DE, de() - 1); break;
        case 0x1C: /* INC E        */ e = alu_add(e, 1); break;
        case 0x1D: /* DEC E        */ e = alu_sub(e, 1); break;
        case 0x1E: /* LD E, #      */ e = fetch(); break;
        case 0x1F: /* RRA          */ break;

        case 0x20: /* JR NZ, #     */ break;
        case 0x21: /* LD HL, ##    */ putw(HL, fetch_word()); break;
        case 0x22: /* LD (##), HL  */ break;
        case 0x23: /* INC HL       */ putw(HL, hl() + 1); break;
        case 0x24: /* INC H        */ h = alu_add(h, 1); break;
        case 0x25: /* DEC H        */ h = alu_sub(h, 1); break;
        case 0x26: /* LD D, #      */ d = fetch(); break;
        case 0x27: /* DAA          */ break;

        case 0x28: /* JR Z, #      */ break;
        case 0x29: /* ADD HL, HL   */ break;
        case 0x2A: /* LD HL, (##)  */ break;
        case 0x2B: /* DEC HL       */ putw(HL, hl() - 1); break;
        case 0x2C: /* INC L        */ l = alu_add(l, 1); break;
        case 0x2D: /* DEC L        */ l = alu_sub(l, 1); break;
        case 0x2E: /* LD L, #      */ l = fetch(); break;
        case 0x2F: /* CPL          */ break;

        case 0x30: /* JR NC, #     */ break;
        case 0x31: /* LD SP, ##    */ sp = fetch_word(); break;
        case 0x32: /* LD (##), A   */ break;
        case 0x33: /* INC SP       */ sp = sp + 1; break;
        case 0x34: /* INC (HL)     */ write(hl(), alu_add(read(hl()), 1)); break;
        case 0x35: /* DEC (HL)     */ write(hl(), alu_sub(read(hl()), 1)); break;
        case 0x36: /* LD (HL), #   */ write(hl(), fetch()); break;
        case 0x37: /* SCF          */ break;

        case 0x38: /* JR C, #      */ break;
        case 0x39: /* ADD HL, SP   */ break;
        case 0x3A: /* LD A, (##)   */ break;
        case 0x3B: /* DEC SP       */ sp = sp - 1; break;
        case 0x3C: /* INC A        */ a = alu_add(a, 1); break;
        case 0x3D: /* DEC A        */ a = alu_sub(a, 1); break;
        case 0x3E: /* LD A, #      */ a = fetch(); break;
        case 0x3F: /* CCF          */ break;
    }
}
