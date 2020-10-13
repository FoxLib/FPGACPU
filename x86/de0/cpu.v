module cpu
(
    // Основной контур для процессора
    input   wire        clock,              // 25 mhz
    output  reg  [19:0] address,
    input   wire [ 7:0] i_data,             // i_data = ram[address]
    output  reg  [ 7:0] o_data,
    output  reg         we
);

wire [15:0] _debug_ = seg[SEG_CS];

`include "cpu_decl.v"

// Выбор текущего адреса
assign address = bus ? {seg[segment_id], 4'h0} + ea : {seg[SEG_CS], 4'h0} + ip;

// Исполнительный блок
always @(posedge clock) begin

    case (fn)

        // Сброс перед запуском инструкции
        0: begin

            opcode      <= 0;
            segment_id  <= SEG_DS;          // Значение сегмента по умолчанию DS:
            segment_px  <= 1'b0;            // Наличие сегментного префикса
            rep  <= 2'b0;   // Нет префикса REP:
            fn   <= 1;      // Номер главной фунции
            cn   <= 0;      // Вспомогательные
            i_dir  <= 0;    // Ширина операнда
            i_size <= 0;    // Направление

            // Пропуск 32-х битных префиксов
            casex (i_data)

                8'b0110_010x, // FS, GS
                8'b0110_011x, // opsize, adsize
                8'b1110_0000: begin fn <= 0; ip <= ip + 1; end

            endcase

        end

        // Распознание опкода
        1: begin

            casex (i_data)

                8'b0000_1111: begin opcode[8] <= 1'b1; fn <= 2'h3; end // Префикс расширения
                8'b001x_x110: begin segment_id <= i_data[4:3]; segment_px <= 1'b1; end // Сегментные префиксы
                8'b1110_001x: begin rep <= i_data[1:0]; end // REPNZ, REPZ
                default: begin // Переход к исполнению инструкции

                    opcode <= i_data;

                    // Параметры по умолчанию
                    i_size <= opcode[0];
                    i_dir  <= opcode[1];

                    // Определить наличие байта ModRM для опкода
                    casex (i_data)

                        8'b00xxx0xx, 8'b1000xxxx, 8'b1100000x, 8'b110001xx,
                        8'b110100xx, 8'b11011xxx, 8'b1111x11x, 8'b0110001x,
                        8'b011010x1: fn <= 2;
                        default: fn <= 3;

                    endcase

                end

            endcase

            ip <= ip + 1;

        end

        // Считывание MODRM
        2: case (cn)

            // Считывание адреса или регистров
            0: begin

                // Первый операнд (i_dir=1 будет выбрана rm-часть)
                case (i_dir ? i_data[2:0] : i_data[5:3])

                    3'b000: op1 <= i_size ? r16[REG_AX] : r16[REG_AX][ 7:0];
                    3'b001: op1 <= i_size ? r16[REG_CX] : r16[REG_CX][ 7:0];
                    3'b010: op1 <= i_size ? r16[REG_DX] : r16[REG_DX][ 7:0];
                    3'b011: op1 <= i_size ? r16[REG_BX] : r16[REG_BX][ 7:0];
                    3'b100: op1 <= i_size ? r16[REG_SP] : r16[REG_AX][15:8];
                    3'b101: op1 <= i_size ? r16[REG_BP] : r16[REG_CX][15:8];
                    3'b110: op1 <= i_size ? r16[REG_SI] : r16[REG_DX][15:8];
                    3'b111: op1 <= i_size ? r16[REG_DI] : r16[REG_BX][15:8];

                endcase

                // Второй операнд (i_dir=1 будет выбрана reg-часть)
                case (i_dir ? i_data[5:3] : i_data[2:0])

                    3'b000: op2 <= i_size ? r16[REG_AX] : r16[REG_AX][ 7:0];
                    3'b001: op2 <= i_size ? r16[REG_CX] : r16[REG_CX][ 7:0];
                    3'b010: op2 <= i_size ? r16[REG_DX] : r16[REG_DX][ 7:0];
                    3'b011: op2 <= i_size ? r16[REG_BX] : r16[REG_BX][ 7:0];
                    3'b100: op2 <= i_size ? r16[REG_SP] : r16[REG_AX][15:8];
                    3'b101: op2 <= i_size ? r16[REG_BP] : r16[REG_CX][15:8];
                    3'b110: op2 <= i_size ? r16[REG_SI] : r16[REG_DX][15:8];
                    3'b111: op2 <= i_size ? r16[REG_DI] : r16[REG_BX][15:8];

                endcase

                // Подготовка эффективного адреса
                case (i_data[2:0])

                    3'b000: ea <= r16[REG_BX] + r16[REG_SI];
                    3'b001: ea <= r16[REG_BX] + r16[REG_DI];
                    3'b010: ea <= r16[REG_BP] + r16[REG_SI];
                    3'b011: ea <= r16[REG_BP] + r16[REG_DI];
                    3'b100: ea <= r16[REG_SI];
                    3'b101: ea <= r16[REG_DI];
                    3'b110: ea <= i_data[7:6] == 2'b00 ? 0 : r16[REG_BP]; // disp16 | bp
                    3'b111: ea <= r16[REG_BX];

                endcase

                modrm <= i_data;

            end

        endcase

        // Исполнение инструкции
        3: begin
        end

    endcase


end

endmodule

