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

            // INC|DEC r16 Все флаги меняются, кроме флага CF
            8'b01_00x_xxx: begin r[opcode[2:0]] <= result; sub <= sub_opcode; flags[11:1] <= flags_out[11:1]; end

            // PUSH r16
            8'b000_xx_110,
            8'b01_010_xxx: case (fn)

                0: begin fn   <= 1; out <= opcode[6] ? r[opc20][15:8] : s[opc43][15:8]; r[reg_sp] <= eff; eff <= eff + 1; end
                1: begin wren <= 0; sub <= sub_opcode;     swi <= 1'b0; end

            endcase

            // POP r16
            8'b000_xx_111,
            8'b01_011_xxx: case (fn)

                0: begin fn  <= 1; eff <= eff + 1; wb[7:0] <= data; end
                1: begin if (opcode[6]) r[opc20] <= {data, wb[7:0]}; else s[opc43] <= {data, wb[7:0]}; swi <= 0; sub <= sub_opcode; end

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

        endcase

    endcase

end

endmodule
