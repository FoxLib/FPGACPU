#include <string.h>

#include "ui.h"
#include "cpu.h"
#include "fonts.h"
#include "disasm.h"

// Установка цвета
void CPU::color(int fore, int back) {

    color_fore = fore;
    color_back = back;
}

// Печать одного символа на хосте (символ размером 8x10)
void CPU::print_char(int x, int y, unsigned char ch) {

    int i, j;
    for (i = 0; i < 8; i++) {

        int mask = sysfont[8*ch + i];
        for (j = 0; j < 8; j++) {

            int color = (mask & (1<<(7-j))) ? color_fore : color_back;

            if (color >= 0) {
                psetmini(8*x+j, 10*y+i, color);
            }
        }
    }
}

// Печать строки с переносом по Y
void CPU::print(int x, int y, const char* s) {

    int i = 0;
    while (s[i]) {

        print_char(x, y, s[i]);

        x++;
        if (8*x >= width) {
            x = 0;
            y++;
        }

        i++;
    }
}

// Очистка экрана в задний цвет
void CPU::cls() {

    for (int i = 0; i < height; i++)
    for (int j = 0; j < width; j++)
        pset(j, i, color_back);
}

// Прочитать байт дизассемблера
int CPU::ds_fetch_byte() {

    int b = mem[ds_ad];
    ds_ad = (ds_ad + 1) & 0xffff;
    ds_size++;
    return b;
}

// Прочитать слово дизассемблера
int CPU::ds_fetch_word() {

    int l = ds_fetch_byte();
    int h = ds_fetch_byte();
    return (h<<8) | l;
}

// Прочитать относительный операнд
int CPU::ds_fetch_rel() {

    int r8 = ds_fetch_byte();
    return ((r8 & 0x80) ? r8 - 0x100 : r8) + ds_ad;
}

// Дизассемблирование 1 линии
int CPU::disasm_line(int addr) {

    int op, df;

    ds_opcode[0]  = 0;
    ds_operand[0] = 0;
    ds_ad   = addr;
    ds_size = 0;

    // -----------------------------------------------------------------
    // Считывание опкода и префиксов
    // -----------------------------------------------------------------

    op = ds_fetch_byte();

    // -----------------------------------------------------------------
    // Разбор опкода и операндов
    // -----------------------------------------------------------------

    if (op == 0xED) {

        op = ds_fetch_byte();

        int a = (op & 0x38) >> 3;
        int b = (op & 0x07);
        int f = (op & 0x30) >> 4;

        // 01xx x000
        if ((op & 0xc7) == 0x40)      { sprintf(ds_opcode, "in");  sprintf(ds_operand, "%s, (c)", a == 6 ? "?" : ds_reg8[a]); }
        else if ((op & 0xc7) == 0x41) { sprintf(ds_opcode, "out"); sprintf(ds_operand, "(c), %s", a == 6 ? "0" : ds_reg8[a]); }
        // 01xx x010
        else if ((op & 0xc7) == 0x42) { sprintf(ds_opcode, op & 8 ? "adc" : "sbc"); sprintf(ds_operand, "hl, %s", ds_reg16[f]); }
        // 01xx b011
        else if ((op & 0xcf) == 0x43) { sprintf(ds_opcode, "ld"); sprintf(ds_operand, "($%04x), %s", ds_fetch_word(), ds_reg16[f]); }
        else if ((op & 0xcf) == 0x4b) { sprintf(ds_opcode, "ld"); sprintf(ds_operand, "%s, ($%04x)", ds_reg16[f], ds_fetch_word()); }
        // 01xx x10b
        else if ((op & 0xc7) == 0x44) { sprintf(ds_opcode, "neg"); }
        else if (op == 0x4d) sprintf(ds_opcode, "reti");
        else if ((op & 0xc7) == 0x45) { sprintf(ds_opcode, "retn"); }
        // 01xx x110
        else if ((op & 0xc7) == 0x46) { sprintf(ds_opcode, "im"); sprintf(ds_operand, "%x", ds_im[a]); }
        else switch (op) {

            case 0x47: sprintf(ds_opcode, "ld"); sprintf(ds_operand, "i, a"); break;
            case 0x4f: sprintf(ds_opcode, "ld"); sprintf(ds_operand, "r, a"); break;
            case 0x57: sprintf(ds_opcode, "ld"); sprintf(ds_operand, "a, i"); break;
            case 0x5f: sprintf(ds_opcode, "ld"); sprintf(ds_operand, "a, r"); break;
            case 0x67: sprintf(ds_opcode, "rrd"); break;
            case 0x6f: sprintf(ds_opcode, "rld"); break;

            case 0xa0: sprintf(ds_opcode, "ldi"); break;
            case 0xa1: sprintf(ds_opcode, "cpi"); break;
            case 0xa2: sprintf(ds_opcode, "ini"); break;
            case 0xa3: sprintf(ds_opcode, "outi"); break;
            case 0xa8: sprintf(ds_opcode, "ldd"); break;
            case 0xa9: sprintf(ds_opcode, "cpd"); break;
            case 0xaa: sprintf(ds_opcode, "ind"); break;
            case 0xab: sprintf(ds_opcode, "outd"); break;

            case 0xb0: sprintf(ds_opcode, "ldir"); break;
            case 0xb1: sprintf(ds_opcode, "cpir"); break;
            case 0xb2: sprintf(ds_opcode, "inir"); break;
            case 0xb3: sprintf(ds_opcode, "otir"); break;
            case 0xb8: sprintf(ds_opcode, "lddr"); break;
            case 0xb9: sprintf(ds_opcode, "cpdr"); break;
            case 0xba: sprintf(ds_opcode, "indr"); break;
            case 0xbb: sprintf(ds_opcode, "otdr"); break;

            default:

                sprintf(ds_opcode, "undef?"); break;

        }

    }
    else if (op == 0xCB) {

        op = ds_fetch_byte();

        int a = (op & 0x38) >> 3;
        int b = (op & 0x07);

        // 00xxxrrr SHIFT
        if ((op & 0xc0) == 0x00) {

            sprintf(ds_opcode, "%s", ds_bits[a]);
            sprintf(ds_operand, "%s", ds_reg8[b]);

        }
        else {

            if ((op & 0xc0) == 0x40) sprintf(ds_opcode, "bit");
            if ((op & 0xc0) == 0x80) sprintf(ds_opcode, "res");
            if ((op & 0xc0) == 0xc0) sprintf(ds_opcode, "set");

            sprintf(ds_operand, "%x, %s", a, ds_reg8[b]);
        }

    } else {

        // Имя опкода
        sprintf(ds_opcode, "%s", ds_mnemonics[op]);

        int a = (op & 0x38) >> 3;
        int b = (op & 0x07);

        // Имя HL в зависимости от префикса
        char hlname[4];
        sprintf(hlname, "hl");

        // Инструкции перемещения LD
        if (op >= 0x40 && op < 0x80) {

            if (a == 6 && b == 6) {
                /* halt */
            }
            else { sprintf(ds_operand, "%s, %s", ds_reg8[a], ds_reg8[b]); }
        }
        // Арифметико-логика
        else if (op >= 0x80 && op < 0xc0) {
            sprintf(ds_operand, "%s", ds_reg8[b]);
        }
        // LD r16, **
        else if (op == 0x01 || op == 0x11 || op == 0x21 || op == 0x31) {

            df = ds_fetch_word();
            sprintf(ds_operand, "%s, $%04x", ds_reg16[((op & 0x30) >> 4)], df);
        }
        // 00xx x110 LD r8, i8
        else if ((op & 0xc7) == 0x06) {
            sprintf(ds_operand, "%s, $%02x", ds_reg8[a], ds_fetch_byte());
        }
        // 00_xxx_10x
        else if ((op & 0xc7) == 0x04 || (op & 0xc7) == 0x05) {
            sprintf(ds_operand, "%s", ds_reg8[a]);
        }
        // 00xx x011
        else if ((op & 0xc7) == 0x03) {
            sprintf(ds_operand, "%s", ds_reg16[((op & 0x30) >> 4)]);
        }
        // 00xx 1001
        else if ((op & 0xcf) == 0x09) {
            sprintf(ds_operand, "%s, %s", ds_reg16[2], ds_reg16[((op & 0x30) >> 4)]);
        }
        else if (op == 0x02) sprintf(ds_operand, "(bc), a");
        else if (op == 0x08) sprintf(ds_operand, "af, af'");
        else if (op == 0x0A) sprintf(ds_operand, "a, (bc)");
        else if (op == 0x12) sprintf(ds_operand, "(de), a");
        else if (op == 0x1A) sprintf(ds_operand, "a, (de)");
        else if (op == 0xD3) sprintf(ds_operand, "($%02x), a", ds_fetch_byte());
        else if (op == 0xDB) sprintf(ds_operand, "a, ($%02x)", ds_fetch_byte());
        else if (op == 0xE3) sprintf(ds_operand, "(sp), %s", hlname);
        else if (op == 0xE9) sprintf(ds_operand, "(%s)", hlname);
        else if (op == 0xEB) sprintf(ds_operand, "de, %s", hlname);
        else if (op == 0xF9) sprintf(ds_operand, "sp, %s", hlname);
        else if (op == 0xC3 || op == 0xCD) sprintf(ds_operand, "$%04x", ds_fetch_word());
        else if (op == 0x22) { b = ds_fetch_word(); sprintf(ds_operand, "($%04x), %s", b, hlname); }
        else if (op == 0x2A) { b = ds_fetch_word(); sprintf(ds_operand, "%s, ($%04x)", hlname, b); }
        else if (op == 0x32) { b = ds_fetch_word(); sprintf(ds_operand, "($%04x), a", b); }
        else if (op == 0x3A) { b = ds_fetch_word(); sprintf(ds_operand, "a, ($%04x)", b); }
        else if (op == 0x10 || op == 0x18) { sprintf(ds_operand, "$%04x", ds_fetch_rel()); }
        // 001x x000 JR c, *
        else if ((op & 0xe7) == 0x20) sprintf(ds_operand, "%s, $%04x", ds_cc[(op & 0x18)>>3], ds_fetch_rel());
        // 11xx x000 RET *
        else if ((op & 0xc7) == 0xc0) sprintf(ds_operand, "%s", ds_cc[a]);
        // 11xx x010 JP c, **
        // 11xx x100 CALL c, **
        else if ((op & 0xc7) == 0xc2 || (op & 0xc7) == 0xc4) sprintf(ds_operand, "%s, $%04x", ds_cc[a], ds_fetch_word());
        // 11xx x110 ALU A, *
        else if ((op & 0xc7) == 0xc6) sprintf(ds_operand, "$%02x", ds_fetch_byte());
        // 11xx x111 RST #
        else if ((op & 0xc7) == 0xc7) sprintf(ds_operand, "$%02x", op & 0x38);
        // 11xx 0x01 PUSH/POP r16
        else if ((op & 0xcb) == 0xc1) sprintf(ds_operand, "%s", ds_reg16af[ ((op & 0x30) >> 4)] );
    }

    return ds_size;
}

// Перерисовать дизассемблер
void CPU::disasm_repaint() {

    char tmp[256];

    ds_start &= 0xffff;

    int i, j, k, catched = 0;
    int bp_found;
    int ds_current = ds_start;

    ds_match_row = 0;

    // Очистка экрана
    color(0xffffff, 0);
    cls();

    // Начать отрисовку сверху вниз
    for (i = 0; i < 36; i++) {

        int dsy  = i + 1;
        int size = this->disasm_line(ds_current);

        // Поиск прерывания
        bp_found = 0;
        for (int j = 0; j < bp_count; j++) {
            if (bp_rows[j] == ds_current) {
                bp_found = 1;
                break;
            }
        }

        // Запись номера строки
        ds_rowdis[i] = ds_current;

        // Курсор находится на текущей линии
        if (ds_cursor == ds_current) {

            color(0xffffff, bp_found ? 0xc00000 : 0x0000f0);
            print(0, dsy, "                                         ");
            sprintf(tmp, "%04X", ds_current); print(1, dsy, tmp);

            ds_match_row = i;
            catched = 1;
        }
        // Либо на какой-то остальной
        else {

            color(0x00ff00, bp_found ? 0x800000 : 0);
            print(0, dsy, "                               ");

            // Выдача адреса
            sprintf(tmp, "%04X", ds_current); print(1, dsy, tmp);
            color(0x80c080, bp_found ? 0x800000 : 0);
        }

        // Текущее положение PC
        if (ds_current == pc) print(0, dsy, "\x10");

        // Печатать опкод в верхнем регистре
        sprintf(tmp, "%s", ds_opcode);
        for (k = 0; k < (int) strlen(tmp); k++) if (tmp[k] >= 'a' && tmp[k] <= 'z') tmp[k] += ('A' - 'a');
        print(7+6,  dsy, tmp); // Опкод

        // Печатать операнды в верхнем регистре
        sprintf(tmp, "%s", ds_operand);
        for (k = 0; k < (int) strlen(tmp); k++) if (tmp[k] >= 'a' && tmp[k] <= 'z') tmp[k] += ('A' - 'a');
        print(7+12, dsy, tmp); // Операнд

        // Вывод микродампа
        if  (ds_cursor == ds_current)
             color(0xf0f0f0, bp_found ? 0xc00000 : 0x0000f0);
        else color(0xa0a0a0, bp_found ? 0x800000 : 0x000000);

        // Максимум 3 байта
        if (size == 1) { sprintf(tmp, "%02X",          mem[ds_current]);                                       print(6, dsy, tmp); }
        if (size == 2) { sprintf(tmp, "%02X%02X",      mem[ds_current], mem[ds_current+1]);                    print(6, dsy, tmp); }
        if (size == 3) { sprintf(tmp, "%02X%02X%02X",  mem[ds_current], mem[ds_current+1], mem[ds_current+2]); print(6, dsy, tmp); }
        if (size  > 3) { sprintf(tmp, "%02X%02X%02X+", mem[ds_current], mem[ds_current+1], mem[ds_current+2]); print(6, dsy, tmp); }

        // Следующий адрес
        ds_current = (ds_current + size) & 0xffff;
    }

    // В последней строке будет новая страница
    ds_rowdis[36] = ds_current;

    // Проверка на "вылет"
    // Сдвиг старта на текущий курсор
    if (catched == 0) {

        ds_start = ds_cursor;
        disasm_repaint();
    }

    color(0xc0c0c0, 0);

    // Вывод содержимого регистров
    sprintf(tmp, "B: %02X  B': %02X  S: %c", b, b_, f & 0x80 ? '1' : '-'); print(42, 1, tmp);
    sprintf(tmp, "C: %02X  C': %02X  Z: %c", c, c_, f & 0x40 ? '1' : '-'); print(42, 2, tmp);
    sprintf(tmp, "D: %02X  D': %02X  Y: %c", d, d_, f & 0x20 ? '1' : '-'); print(42, 3, tmp);
    sprintf(tmp, "E: %02X  E': %02X  H: %c", e, e_, f & 0x10 ? '1' : '-'); print(42, 4, tmp);
    sprintf(tmp, "H: %02X  H': %02X  X: %c", h, h_, f & 0x08 ? '1' : '-'); print(42, 5, tmp);
    sprintf(tmp, "L: %02X  L': %02X  V: %c", l, l_, f & 0x04 ? '1' : '-'); print(42, 6, tmp);
    sprintf(tmp, "A: %02X  A': %02X  N: %c", a, a_, f & 0x02 ? '1' : '-'); print(42, 7, tmp);
    sprintf(tmp, "F: %02X  F': %02X  C: %c", f, f_, f & 0x01 ? '1' : '-'); print(42, 8, tmp);
    sprintf(tmp, "F: %02X  F': %02X  C: %c", f, f_, f & 0x01 ? '1' : '-'); print(42, 8, tmp);

    sprintf(tmp, "BC: %04X", (b<<8) | c); print(42, 10, tmp);
    sprintf(tmp, "DE: %04X", (d<<8) | e); print(42, 11, tmp);
    sprintf(tmp, "HL: %04X", (h<<8) | l); print(42, 12, tmp);
    sprintf(tmp, "SP: %04X", sp);         print(42, 13, tmp);
    sprintf(tmp, "AF: %04X", (a<<8) | f); print(42, 14, tmp);

    sprintf(tmp, "(HL): %02X", mem[ (h<<8) | l ]); print(42, 15, tmp);
    sprintf(tmp, "(SP): %02X", mem[ sp ]); print(42, 16, tmp);
    sprintf(tmp, "PC: %04X", pc);  print(51, 12, tmp);

    sprintf(tmp, "IFF0:  %01X", iff0);  print(51, 15, tmp);
    sprintf(tmp, "IFF1:  %01X", iff1);  print(51, 16, tmp);

    // Вывести дамп памяти
    for (i = 0; i < 15; i++) {

        for (k = 0; k < 8; k++) {

            sprintf(tmp, "%02X", read(8*i+k+ds_dumpaddr));
            color(k % 2 ? 0x40c040 : 0xc0f0c0, 0);
            print(47 + 2*k, i + 23, tmp);
        }

        color(0x909090, 0);
        sprintf(tmp, "%04X", ds_dumpaddr + 8*i);
        print(42, i + 23, tmp);
    }
    color(0xf0f0f0, 0); print(42, 22, "ADDR  0 1 2 3 4 5 6 7");

    // Прерывание
    color(0xffff00, 0); print(42, 18, "F2");
    color(0x00ffff, 0); print(45, 18, "Brk");

    // Один шаг с заходом
    color(0xffff00, 0); print(42, 19, "F7");
    color(0x00ffff, 0); print(45, 19, "Step");

    // Запуск программы
    color(0xffff00, 0); print(42, 20, "F9");
    color(0x00ffff, 0); print(45, 20, "Run");

    // Переключить экраны
    color(0xffff00, 0); print(50, 18, "F5");
    color(0x00ffff, 0); print(53, 18, "Swi");

    // Один шаг с заходом
    color(0xffff00, 0); print(50, 19, "F6");
    color(0x00ffff, 0); print(53, 19, "Intr");

    // Один шаг с заходом
    color(0xffff00, 0); print(50, 20, "F8");
    color(0x00ffff, 0); print(53, 20, "Over");

    // Некоторые индикаторы
    color(0x808080, 0); sprintf(tmp, "TStates: %d", cycles); print(4, 37, tmp);

    // Halted
    color(halt ? 0xffff00 : 0x707070, 0);
    print(1, 37, "H");

    // Enabled Halt
    color(enable_halt ? 0xffff00 : 0x707070, 0);
    print(2, 37, "E");
}
