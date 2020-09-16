module cpu
(
    // Основной контур для процессора
    input   wire        clock,              // 25 mhz
    output  reg  [19:0] address,
    input   wire [ 7:0] i_data,             // i_data = ram[address]
    output  reg  [ 7:0] o_data,
    output  reg         we
);

`include "cpu_decl.v"

// Выбор указателя в памяти
always @* begin

    if (pmode) begin
        address = swi ? segment[seg_id][31:0] + ea : segment[SEG_CS][31:0] + ip;
    end else begin
        address = swi ? {s16[seg_id], 4'h0} + ea[15:0] : {s16[SEG_CS], 4'h0} + ip[15:0];
    end

end

// Исполнительный блок
always @(posedge clock) begin

    case (cycle)

        // Сброс параметров перед перезапуском инструкции
        0: begin

            cycle       <= 1;
            opcode      <= 0;
            seg_id      <= SEG_DS;          // Значение сегмента по умолчанию DS:
            seg_pre     <= 1'b0;            // Наличие сегментного префикса
            opsize      <= def_opsize;
            adsize      <= def_adsize;
            rep         <= 2'b0;

        end

        // Распознание опкода
        1: begin

            casex (i_data)

                // Префикс расширения
                8'b0000_1111: begin opcode[8] <= 1'b1; cycle <= 2; end

                // Сегментные префиксы
                8'b001x_x110: begin seg_id <= i_data[4:3]; seg_pre <= 1'b1; end
                8'b0110_010x: begin seg_id <= 4+i_data[0]; seg_pre <= 1'b1; end // FS: GS:

                // Размер операнда и адреса (16/32)
                8'b0110_0110: begin opsize <= ~opsize; end
                8'b0110_0111: begin adsize <= ~adsize; end
                8'b1110_0000: begin /* бесполезный префикс lock */ end

                // REPNZ, REPZ
                8'b1110_001x: begin rep <= i_data[1:0]; end

                // Переход к исполнению инструкции
                default: cycle <= 2;

            endcase

            opcode <= i_data;
            ip     <= ipnext;

        end

    endcase


end

endmodule

