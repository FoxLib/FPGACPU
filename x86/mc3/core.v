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

        `include "fetch.v"
        `include "modrm.v"

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
            8'b01_010_xxx: case (fn)

                0: begin fn   <= 1; out <= r[opc20][15:8]; r[reg_sp] <= eff; eff <= eff + 1; end
                1: begin wren <= 0; sub <= sub_opcode;     swi <= 1'b0; end

            endcase

            // POP r16
            8'b01_011_xxx: case (fn)

                0: begin fn  <= 1; eff <= eff + 1;    wb[7:0] <= data; end
                1: begin swi <= 0; sub <= sub_opcode; r[opc20] <= {data, wb[7:0]}; end

            endcase

            // J<ccc>, JMP *
            8'b01_11x_xxx: begin sub <= sub_opcode; ip <= ip + 1 + {{8{data[7]}}, data[7:0]}; end

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

        // ===============================
        // Обратная запись в байт ModRM
        // или в память (зависит от modrm)
        // По завершении записи swi -> 0
        // ===============================

        sub_wb: case (fn2)

            // Запись в регистр
            0: begin

                // Запись либо в регистр, либо в reg-часть от r/m
                if (modrm[7:6] == 2'b11 || dir) begin

                    if (bit16) begin

                        if (dir) r[ modrm[5:3] ] <= wb[15:0];
                        else     r[ modrm[2:0] ] <= wb[15:0];

                    end
                    // 8 bit
                    else begin

                        if (dir) begin

                            if (modrm[5]) r[ modrm[4:3] ][15:8] <= wb[7:0];
                            else          r[ modrm[4:3] ][ 7:0] <= wb[7:0];

                        end else begin

                            if (modrm[2]) r[ modrm[1:0] ][15:8] <= wb[7:0];
                            else          r[ modrm[1:0] ][ 7:0] <= wb[7:0];

                        end

                    end

                    sub <= subret;
                    swi <= 1'b0;

                end
                // Запись в память байта или слова
                else begin

                    wren <= 1'b1;
                    out  <= wb[7:0];
                    fn2  <= 1;

                end

            end

            // Запись 8 бит
            1: begin

                if (bit16) begin fn2 <= 2; eff <= eff + 1; out <= wb[15:8]; end
                else       begin fn2 <= 0; sub <= subret; wren <= 1'b0; swi <= 1'b0; end

            end

            // Запись 16 бит
            2: begin fn2 <= 0; swi <= 1'b0; sub <= subret; wren <= 1'b0; eff <= eff - 1; end

        endcase

    endcase

end

endmodule
