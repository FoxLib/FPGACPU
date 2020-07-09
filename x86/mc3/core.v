/**
 * Intel Core [Cryo Kunitsa Edition]
 * А на самом деле полная лажа 8 битная
 */

module core
(
    // Самые главные пины
    input   wire        clock,          // Опорная частота
    output  wire [19:0] address,        // Указатель на текущий адрес
    input   wire [ 7:0] data,           // Входящие данные
    output  reg  [ 7:0] out,            // Исходящие данные
    output  reg         wren            // Разрешение на запись
);

assign address = swi ? {seg, 4'h0} + eff : {s[seg_cs], 4'h0} + ip;

// ---------------------------------------------------------------------
`include "declare.v"
// ---------------------------------------------------------------------

always @(posedge clock)
begin

    case (sub)

        // ===============================
        // Считывание префиксов и опкода
        // ===============================

        sub_opcode: begin

            ip <= ip + 1;

            casex (data)

                // Загрузка сегмента эффективного адреса
                8'b001x_x110: begin _override <= 1'b1; _seg <= s[ data[4:3] ]; end
                8'b1111_0000: begin /* lock: */ end
                8'b1111_001x: begin _rep <= data[1:0]; end

                // Другие префиксы опускаются, потому что мне лень реализовывать их
                default: begin

                    // Защелкивание кода инструкции и префикса
                     rep   <= _rep;   override <= _override;  seg <= _seg;
                    _rep   <= 2'b00; _override <= 1'b0;      _seg <= s[seg_ds];
                    fn     <= 0;
                    opcode <= data;

                    // Декодирование опкода
                    casex (data)

                        // Инструкции ADD|ADC|SUB|SBB|AND|XOR|OR|CMP <modrm>|Acc,i8/16
                        8'b00_xxx_0xx: begin sub <= sub_modrm; alu <= data53; bit16 <= data[0]; dir <= data[1]; end
                        8'b00_xxx_10x: begin sub <= sub_exec;  alu <= data53; bit16 <= data[0]; end

                    endcase

                end

            endcase

        end

        // ===============================
        // Чтение и разбор байта ModRM
        // ===============================

        sub_modrm: case (fn)

            0: begin

                ip    <= ip + 1;
                modrm <= data;

                // Чтение регистров в операнды
                if (bit16) begin

                    op1 <= dir ? r[data53] : r[data20]; // r/m | reg
                    op2 <= dir ? r[data20] : r[data53]; // reg | r/m

                end else begin

                    if (dir) begin

                        op1 <= data[5] ? rdata43[15:8] : rdata43[7:0]; // reg
                        op2 <= data[2] ? rdata10[15:8] : rdata10[7:0]; // r/m

                    end else begin

                        op1 <= data[2] ? rdata10[15:8] : rdata10[7:0]; // r/m
                        op2 <= data[5] ? rdata43[15:8] : rdata43[7:0]; // reg

                    end
                end

                // Вычисление эффективного адреса
                casex (data)

                    8'b00_xxx_110: eff <= 0; // disp16
                    8'bxx_xxx_000: eff <= r[reg_bx] + r[reg_si];
                    8'bxx_xxx_001: eff <= r[reg_bx] + r[reg_di];
                    8'bxx_xxx_010: eff <= r[reg_bp] + r[reg_si];
                    8'bxx_xxx_011: eff <= r[reg_bp] + r[reg_di];
                    8'bxx_xxx_100: eff <= r[reg_si];
                    8'bxx_xxx_101: eff <= r[reg_di];
                    8'bxx_xxx_110: eff <= r[reg_bp];
                    8'bxx_xxx_111: eff <= r[reg_bx];

                endcase

                // Вычисление эффективного адреса
                casex (data)

                    8'b00_xxx_110,
                    8'b10_xxx_xxx: begin fn <= 1; end // +disp16
                    8'b00_xxx_xxx: begin fn <= 4; swi <= 1'b1; end
                    8'b01_xxx_xxx: begin fn <= 3; end // +disp8
                    8'b11_xxx_xxx: begin sub <= sub_exec; end

                endcase

                // Если ранее был override, то в seg уже будет значение сегментного регистра
                if (override == 1'b0)
                casex (data)

                    8'b0x_xxx_01x, // bp+si | bp+di
                    8'b10_xxx_01x,
                    8'b01_xxx_110, // bp
                    8'b10_xxx_110:  seg <= s[seg_ss];
                    default:        seg <= s[seg_ds];

                endcase

            end

            // Считывание 16 bit disp
            1: begin fn <= 2; ip <= ip + 1; eff       <= eff       + data; end
            2: begin fn <= 4; ip <= ip + 1; eff[15:8] <= eff[15:8] + data; swi <= 1'b1; end

            // Считывание [-128..127]
            3: begin fn <= 4; ip <= ip + 1; eff <= eff + {{8{data[7]}}, data[7:0]}; swi <= 1'b1; end

            // Считывание 8 или 16 бит из памяти
            4: begin

                if (dir) op2 <= data; else op1 <= data;
                if (bit16)
                     begin fn <= 5; eff <= eff + 1; end
                else begin fn <= 0; sub <= sub_exec; end

            end

            // Дочитать старший байт
            5: begin

                if (dir) op2[15:8] <= data; else op1[15:8] <= data;

                fn  <= 0;
                eff <= eff - 1;
                sub <= sub_exec;

            end

        endcase

        // ===============================
        // Исполнение инструкции
        // ===============================

        sub_exec: begin

            /* .. */

        end

    endcase

end

// ---------------------------------------------------------------------
// Объявление арифметико-логического устройства
// ---------------------------------------------------------------------

alu ArithLogicUnit
(
    .alu    (alu),
    .op1    (op1),
    .op2    (op2),
    .flags  (flags),
    .bit16  (bit16)
);

endmodule
