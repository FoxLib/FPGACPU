module cpu
(
    // Основной контур для процессора
    input   wire        clock,              // 25 mhz
    output  reg  [19:0] address,
    input   wire [ 7:0] i_data,             // i_data = ram[address]
    output  reg  [ 7:0] o_data,
    output  reg         we
);

// ------------------------------ ОТЛАДКА
wire [15:0] _debug_ = seg[SEG_CS];
wire        _strob_ = fn == 1;
// ------------------------------

`include "cpu_decl.v"

// Выбор текущего адреса
assign address = bus ? {seg[segment_id], 4'h0} + ea : {seg[SEG_CS], 4'h0} + ip;


// Исполнительный блок
always @(posedge clock) begin

    case (fn)

        // Сброс перед запуском инструкции
        // -------------------------------------------------------------
        START: begin

            opcode      <= 0;
            segment_id  <= SEG_DS;  // Значение сегмента по умолчанию DS:
            segment_px  <= 1'b0;    // Наличие сегментного префикса
            rep    <= 2'b0;     // Нет префикса REP:
            ea     <= 0;        // Эффективный адрес
            fn     <= 1;        // Номер главной фунции
            s1     <= 0;        // Вспомогательный
            we     <= 0;        // Разрешение записи
            i_dir  <= 0;        // Ширина операнда 0=8, 1=16
            i_size <= 0;        // Направление 0=[rm,r], 1=[r,rm]

        end

        // Распознание опкода
        // -------------------------------------------------------------
        LOAD: begin

            casex (i_data)

                8'b0000_1111: begin fn <= 4; end // Префикс расширения
                8'b001x_x110: begin segment_id <= i_data[4:3]; segment_px <= 1; end // Сегментные префиксы
                8'b1110_001x: begin rep <= i_data[1:0]; end // REPNZ, REPZ
                8'b0110_010x, // FS, GS
                8'b0110_011x, // opsize, adsize
                8'b1110_0000: begin /* ничего не делать */ end
                default: begin // Переход к исполнению инструкции


                    // Параметры по умолчанию
                    i_size <= i_data[0];
                    i_dir  <= i_data[1];
                    opcode <= i_data;

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
        // -------------------------------------------------------------
        MODRM: case (s1)

            // Считывание адреса или регистров
            0: begin

                s1    <= 1;
                modrm <= i_data;
                ip    <= ip + 1;

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

                // Выбор сегмента SS: для BP
                if (!segment_px)
                casex (i_data)
                    8'bxx_xxx_01x, // [bp+si|di]
                    8'b01_xxx_110, // [bp+d8|d16]
                    8'b10_xxx_110: segment_id <= SEG_SS;
                endcase

                // Переход сразу к исполнению инструкции: операнды уже получены
                casex (i_data)

                    8'b00_xxx_110: begin s1 <= 2; end // +disp16
                    8'b00_xxx_xxx: begin s1 <= 4; bus <= 1; end // Читать операнд из памяти
                    8'b01_xxx_xxx: begin s1 <= 1; end // +disp8
                    8'b10_xxx_xxx: begin s1 <= 2; end // +disp16
                    8'b11_xxx_xxx: begin fn <= INSTR; end // Перейти к исполению

                endcase

            end

            // Чтение 8 битного signed disp
            1: begin s1 <= 4; ip <= ip + 1; ea <= ea + {{8{i_data[7]}}, i_data}; bus <= 1; end

            // Чтение 16 битного unsigned disp16
            2: begin s1 <= 3; ip <= ip + 1; ea <= ea + i_data; end
            3: begin s1 <= 4; ip <= ip + 1; ea[15:8] <= ea[15:8] + i_data; bus <= 1; end

            // Чтение операнда из памяти 8 bit
            4: begin

                if (i_dir) op2 <= i_data; else op1 <= i_data;
                if (i_size) begin s1 <= 5; ea <= ea + 1; end else fn <= INSTR;

            end

            // Операнд 16 bit
            5: begin

                if (i_dir) op2[15:8] <= i_data; else op1[15:8] <= i_data;

                ea <= ea - 1;
                fn <= INSTR;

            end

        endcase

        // Исполнение инструкции
        // -------------------------------------------------------------
        INSTR: begin
        end

        // Расширенные инструции
        // -------------------------------------------------------------
        EXTEND: begin
        end

        // Прерывание
        // -------------------------------------------------------------
        INTR: begin
        end

        // Сохранение результата ModRM
        // -------------------------------------------------------------
        WBACK: begin
        end

        // Запись в стек
        // -------------------------------------------------------------
        PUSH: begin
        end

        // Чтение из стека
        // -------------------------------------------------------------
        POP: begin
        end

    endcase

end

endmodule

