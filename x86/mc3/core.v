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

// ---------------------------------------------------------------------
`include "declare.v"
// ---------------------------------------------------------------------

always @(posedge clock)
begin

    case (sub)

        `include "fetch.v"      // sub_opcode
        `include "modrm.v"      // sub_modrm
        `include "subwb.v"      // sub_wb

        // Исполнение инструкции
        sub_exec: casex (opcode)

            // ADD|ADC|SUB|SBB|AND|XOR|OR|CMP <modrm>
            8'b00_xxx_0xx: begin

                // Инструкция CMP не пишет результат
                if (alu == alu_cmp)
                     begin sub <= sub_opcode; swi <= 1'b0; end
                else begin sub <= sub_wb;     wb  <= result; end

                flags  <= flags_out;
                subret <= sub_opcode;

            end

            // ADD|ADC|SUB|SBB|AND|XOR|OR|CMP acc,i8/16
            8'b00_xxx_10x: case (fn)

                0: begin ip <= ip + 1; fn <= bit16 ? 1 : 2; op1 <= r[reg_ax]; op2 <= data; end
                1: begin ip <= ip + 1; fn <= 2; op2[15:8] <= data; end
                2: begin

                    sub   <= sub_opcode;
                    flags <= flags_out;

                    // Сохраняется в AL/AX кроме CMP
                    if (alu != alu_cmp) begin

                        if (bit16) r[reg_ax] <= result;
                        else       r[reg_ax][7:0] <= result[7:0];

                    end

                end

            endcase

            // Групповые арифметические
            8'b1000_00xx: case (fn)

                // Переключение режима на immediate
                0: begin fn <= 1; swi <= 0; alu <= modrm[5:3]; end

                // Считывание imm8
                1: begin

                    ip  <= ip + 1;
                    fn  <= opcode[1:0] == 2'b01 ? 2 : 3;
                    op2 <= opcode[1:0] == 2'b11 ? {{8{data[7]}}, data[7:0]} : data;

                end

                // Считывание imm16
                2: begin ip <= ip + 1; fn <= 3; op2[15:8] <= data; end

                // Запись результата
                3: begin

                    flags <= flags_out;
                    if (modrm[5:3] == alu_cmp)
                         begin sub <= sub_opcode; end
                    else begin sub <= sub_wb; wb <= result; swi <= 1'b1; end

                end

            endcase

            // INC|DEC r16 Все флаги меняются, кроме флага CF
            8'b01_00x_xxx: begin r[opcode[2:0]] <= result; sub <= sub_opcode; flags[11:1] <= flags_out[11:1]; end

            // PUSH xxx
            8'b0101_0xxx,
            8'b000x_x110,
            8'b1001_1100:
            case (fn)

                0: begin

                    fn <= 1; r[reg_sp] <= eff; eff <= eff + 1;

                    casex (opcode)

                        8'b0101_0xxx: out <= r[opc20][15:8];
                        8'b000x_x110: out <= s[opc43][15:8];
                        8'b0101_0xxx: out <= flags[11:8];

                    endcase

                end

                1: begin wren <= 0; sub <= sub_opcode;     swi <= 1'b0; end

            endcase

            // POP xxx
            8'b000x_x111,
            8'b0101_1xxx,
            8'b1001_1101:
            case (fn)

                0: begin fn <= 1; eff <= eff + 1; wb[7:0] <= data; end
                1: begin

                    swi <= 0;
                    sub <= sub_opcode;

                    casex (opcode)

                        8'b0101_1xxx: r[opc20] <= {data, wb[7:0]};
                        8'b000x_x111: s[opc43] <= {data, wb[7:0]};
                        8'b1001_1101: flags    <= {data[3:0], wb[7:0]};

                    endcase

                end

            endcase

            // J<ccc>, JMP *
            8'b0111_xxxx,
            8'b1110_1011: begin sub <= sub_opcode; ip <= ip + 1 + {{8{data[7]}}, data[7:0]}; end

            // MOV r, i8/16
            8'b10_11x_xxx: case (fn)

                // Прочесть младший байт
                0: begin

                    fn <= 1;
                    ip <= ip + 1;
                    wb[7:0] <= data;

                    if (opcode[3] == 1'b0) begin

                        sub <= sub_opcode;
                        if (opcode[2]) r[ opcode[1:0] ][15:8] <= data;
                        else           r[ opcode[1:0] ][ 7:0] <= data;

                    end

                end

                // Прочесть старший байт
                1: begin r[ opcode[2:0] ] <= {data, wb[7:0]}; sub <= sub_opcode; ip <= ip + 1; end

            endcase

            // MOV rm,r | r,rm
            8'b1000_10xx: begin wb <= op2; sub <= sub_wb; end

        endcase

    endcase

end

endmodule
