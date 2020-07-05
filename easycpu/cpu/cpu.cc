#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "cpu.h"

static const char* cond[4] = {"NC", "C", "NZ", "Z"};

CPU::CPU() {

    // Инициализаровать экран
    for (int id = 0x0000; id <= 0xFFFF; id++) mem[id] = 0;
    for (int id = 0xF001; id <  0xFFA0; id += 2) mem[id] = 0x07;

    ip = 0;
    up = 0;
    ds = 0;

    cf = 0;
    zf = 0;
    intf = 0;

    regs[15] = 0xE000;
    keyb_cntr = 0;

    screen_update();
}

int CPU::load(int argc, char* argv[]) {

    int l = 0;
    if (argc > 1) {
        FILE* fp = fopen(argv[1], "rb");
        if (fp) {
            fseek(fp, 0, SEEK_END);
            l = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            l = fread(mem, 1, l, fp);
            fclose(fp);
        } else {
            printf("file `%s` not found\n", argv[1]); exit(1);
        }
    }
    return l;
}

void CPU::fatal(const char* err) {
    printf("[%04x] %s\n", ip, err);
    exit(1);
}

// Обновление по адресу
void CPU::update_char(int addr) {

    addr &= 0xFFE;
    byte ch   = mem[0xF000 + addr + 0];
    byte attr = mem[0xF000 + addr + 1];

    int fr = attr & 0x0F;
    int bg = attr >> 4;
    int col = (addr>>1)%80;
    int row = (addr/160);

    pchar(col, row, ch, fr, bg);
}

// Обновление всего экрана 80x25
void CPU::screen_update() {

    for (int row = 0; row < 25; row++)
    for (int col = 0; col < 80; col++) {
        update_char(160*row + 2*col);
    }
}

// Вывод списка регистров
void CPU::debug() {

    char ts[256];
    int  bg = 1;

    for (int i = 0; i < 25; i++)
    for (int j = 0; j < 80; j++)
        pchar(j, i, ' ', 15, 1);

    color(11, bg);
    for (int i = 0; i < 16; i++) {
        sprintf(ts, "r%02d: %04X", i, regs[i]);
        pout(2, 1 + i, ts);
    }

    sprintf(ts, " IP: %04X", ip); pout(2, 17, ts);
    sprintf(ts, "ACC: %04X", acc); pout(2, 18, ts);
    sprintf(ts, " CF: %d",  cf); pout(2, 19, ts);
    sprintf(ts, " ZF: %d",  zf); pout(2, 20, ts);
    sprintf(ts, " IF: %d",  intf); pout(2, 21, ts);

    // Отладчик
    word cursor = up;
    int  tmp;
    int  match = 0;

    for (int i = 0; i < 23; i++) {

        bg = 1;
        if (ds == cursor) { bg = 3; match = 1; color(15, bg); pout(15, 1 + i, "                              "); }

        // Адрес десу
        color(14, bg); sprintf(ts, "%04X", cursor); pout(16, 1 + i, ts);

        int  pcursor = cursor;
        int  opcode  = mem[ (cursor++) & 0xFFFF ];
        byte lo = opcode & 15;

        strcpy(ts, "--unk--");
        switch (opcode & 0xF0) {

            case 0x00: sprintf(ts, "LDI     r%d, $%04X", lo, mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
            case 0x10:

                switch (lo) {

                    case 0x00: sprintf(ts, "LDA     [$%04X]", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x01: sprintf(ts, "STA     [$%04X]", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x02: sprintf(ts, "SHR"); break;
                    case 0x03: sprintf(ts, "LDA     $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x04: sprintf(ts, "SWAP"); break;
                    case 0x05: sprintf(ts, "CALL    $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x06: sprintf(ts, "RET"); break;
                    case 0x07: sprintf(ts, "BRK"); break;
                    case 0x08: sprintf(ts, "RETI"); break;
                    case 0x09: sprintf(ts, "CLI"); break;
                    case 0x0A: sprintf(ts, "STI"); break;
                    case 0x0B: sprintf(ts, "CLH"); break;
                }
                break;

            case 0x20: sprintf(ts, "LDA     [r%d]", lo); break;
            case 0x30: sprintf(ts, "STA     [r%d]", lo); break;
            case 0x40: sprintf(ts, "LDA     r%d", lo); break;
            case 0x50: sprintf(ts, "STA     r%d", lo); break;
            case 0x60: sprintf(ts, "ADD     r%d", lo); break;
            case 0x70: sprintf(ts, "SUB     r%d", lo); break;
            case 0x80:

                switch (lo) {

                    // BRA *
                    case 0x00:

                        tmp = mem[cursor++]; if (tmp & 0x80) tmp -= 256;
                        sprintf(ts, "BRA     $%04X", cursor + tmp);
                        break;

                    // JMP **
                    case 0x01: sprintf(ts, "JMP     $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x02: sprintf(ts, "JMP NC, $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x03: sprintf(ts, "JMP C,  $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x04: sprintf(ts, "JMP NZ, $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;
                    case 0x05: sprintf(ts, "JMP Z,  $%04X", mem[cursor] + 256*mem[cursor+1]); cursor += 2; break;

                    // BRA <cond>, *
                    case 0x0A:
                    case 0x0B:
                    case 0x0C:
                    case 0x0D:

                        tmp = mem[cursor++]; if (tmp & 0x80) tmp -= 256;
                        sprintf(ts, "BRA %s, $%04X", cond[lo-0x0A], cursor + tmp);
                        break;
                }
                break;

            case 0x90: sprintf(ts, "AND     r%d", lo); break;
            case 0xA0: sprintf(ts, "XOR     r%d", lo); break;
            case 0xB0: sprintf(ts, "ORA     r%d", lo); break;
            case 0xC0: sprintf(ts, "INC     r%d", lo); break;
            case 0xD0: sprintf(ts, "DEC     r%d", lo); break;
            case 0xE0: sprintf(ts, "PUSH    r%d", lo); break;
            case 0xF0: sprintf(ts, "POP     r%d", lo); break;
        }

        cursor &= 0xFFFF;
        color(15, bg); pout(30, 1 + i, ts);

        color(8, bg);
        switch (cursor - pcursor) {

            case 1: sprintf(ts, "%02X", mem[pcursor]); break;
            case 2: sprintf(ts, "%02X %02X", mem[pcursor], mem[pcursor+1]); break;
            case 3: sprintf(ts, "%02X %02X %02X", mem[pcursor], mem[pcursor+1], mem[pcursor+2]); break;
        }
        pout(21, 1 + i, ts);
    }

    // Нет совпадения - снова перерисовать
    if (match == 0) { ds = ip; up = ip; debug(); }
}

// Имитация приходящих данных
void CPU::sendkey(int xt, int press) {

    if (press) {
        keyb_code_in = xt;
    } else if ((xt & 0xFF) == 0xE0) {
        keyb_code_in = ((xt & 0xFF00) << 8) | 0xF0E0;
    } else {
        keyb_code_in = (xt << 8) | 0xF0;
    }
}

// Отсылка IRQ
void CPU::send_irq() {

    int irq_id = 0;

    if (intf) {

        if (int kn = (keyb_code_in & 0xFF)) {

            mem[0xFFA0] = kn;
            mem[0xFFA1] = (++keyb_cntr) & 0xFF;

            keyb_code_in >>= 8;
            irq_id = 1;
        }
    }

    // Есть вызов прерывания?
    if (irq_id) {

        regs[15] -= 2;
        write(regs[15],   ip & 0xFF);
        write(regs[15]+1, ip >> 8);
        ip   = 2*irq_id;
        intf = 0;
    }
}

// Выполнить шаг и обновить отладчик
void CPU::debugstep() { step(); setdsip(); debug(); }
void CPU::setdsip()   { ds = ip; }

byte CPU::fetch_byte() {

    word b = mem[ip];
    ip = (ip + 1) & 0xFFFF;
    return b;
}

word CPU::fetch_word() {

    byte l = fetch_byte();
    byte h = fetch_byte();
    return 256*h + l;
}

int CPU::fetch_signed() {

    byte b = fetch_byte();
    return b & 0x80 ? b - 256 : b;
}

void CPU::write(word addr, byte data) {

    mem[addr] = data;
    if (addr >= 0xF000) update_char(addr);
}

// Исполнить шаг инструкции
int CPU::step() {

    int tmp;

    opcode  = fetch_byte();
    byte hi = opcode & 0xF0;
    byte lo = opcode & 0x0F;

    switch (hi) {

        // LDI r, **
        case 0x00: regs[lo] = fetch_word(); break;

        // Групповые
        case 0x10:

            switch (lo) {

                // LDA [**] word
                case 0: tmp = fetch_word(); acc = mem[tmp] + 256*mem[tmp + 1]; break;

                // STA [**] word
                case 1: tmp = fetch_word(); write(tmp, acc); write(tmp+1, acc>>8); break;

                // SHR Сдвиг вправо
                case 2: cf = acc & 1; acc = acc >> 1; zf = !acc; break;

                // LDA **
                case 3: acc = fetch_word(); break;

                // SWAP
                case 4: acc = ((acc >> 8) & 0x00FF) | ((acc << 8) & 0xFF00); break;

                // CALL ** : SP-=2, WRITEWORD
                case 5:

                    regs[15] -= 2;
                    tmp = fetch_word();
                    write(regs[15],   ip & 255);
                    write(regs[15]+1, ip >> 8);
                    ip = tmp;
                    break;

                // RET: READWORD, SP+=2
                case 6:
                case 8: // RETI

                    ip = mem[ regs[15] ] + mem[ regs[15]+1 ]*256;
                    regs[15] += 2;
                    if (lo) intf = 1;
                    break;

                // BRK Остановка процессора
                case 7:
                    return 1;

                case 9:  intf = 0; break;
                case 10: intf = 1; break;
                case 11: acc  &= 0x00FF; break;
            }
            break;

        // LDA [r]
        case 0x20: acc = mem[ regs[lo] ] + 256*mem[ regs[lo]+1 ]; break;

        // STA [r]
        case 0x30: write(regs[lo], acc); break;

        // LDA r
        case 0x40: acc = regs[lo]; break;

        // STA r
        case 0x50: regs[lo] = acc; break;

        // ADD r
        case 0x60: tmp = acc + regs[lo]; acc = tmp; zf = !acc; cf = tmp>>16; break;

        // SUB r
        case 0x70: tmp = acc - regs[lo]; cf = (tmp<0?1:0); acc = tmp;  zf = !acc; break;

        // Branch
        case 0x80:

            switch (lo) {

                // BRA *
                case 0: tmp = fetch_byte(); if (tmp & 0x80) { tmp -= 256; } ip += tmp; break;

                // JMP **
                case 1: ip = fetch_word(); break;

                // JMP <cond>, **
                case 2: tmp = fetch_word(); if (!cf) ip = tmp; break;
                case 3: tmp = fetch_word(); if ( cf) ip = tmp; break;
                case 4: tmp = fetch_word(); if (!zf) ip = tmp; break;
                case 5: tmp = fetch_word(); if ( zf) ip = tmp; break;

                // BRA <cond>, *
                case 10: tmp = fetch_signed(); if (!cf) ip += tmp; break;
                case 11: tmp = fetch_signed(); if ( cf) ip += tmp; break;
                case 12: tmp = fetch_signed(); if (!zf) ip += tmp; break;
                case 13: tmp = fetch_signed(); if ( zf) ip += tmp; break;
            }
            break;

        // AND r
        case 0x90: acc &= regs[lo]; zf = !acc; break;

        // XOR r
        case 0xA0: acc ^= regs[lo]; zf = !acc; break;

        // ORA r
        case 0xB0: acc |= regs[lo]; zf = !acc; break;

        // INC|DEC r
        case 0xC0: regs[lo]++; zf = !regs[lo]; break;
        case 0xD0: regs[lo]--; zf = !regs[lo]; break;

        // PUSH Rn
        case 0xE0:

            regs[15] -= 2;
            write(regs[15],   regs[lo] & 255);
            write(regs[15]+1, regs[lo] >> 8);
            break;

        // POP Rn
        case 0xF0:

            regs[15] += 2;
            regs[lo] = mem[ (word)(regs[15]-2) ] + mem[ (word)(regs[15]-1) ]*256;
            break;
    }

    return 0;
}
