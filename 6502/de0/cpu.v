module cpu(

    input   wire        clock,
    output  wire [15:0] address,
    input   wire [ 7:0] i_data,         // Входящие данные
    output  reg  [ 7:0] o_data,         // Выходящие данные
    output  reg         wren,           // Сигнал на запись из памяти
    output  reg         read            // Сигнал на чтение из памяти
);

`include "cpu_decl.v"
`include "cpu_alu.v"

assign address = bus ? cursor : pc;

always @(posedge clock) begin

    case (cstate)

        // Разбор опкода и установка метода адресации
        INI: begin

            opcode  <= i_data;  // Записать опкод
            implied <= 1'b0;    // Операнд не Implied по умолчанию
            read_en <= 1'b1;    // Читать все из памяти (кроме STA)
            cstate  <= EXE;     // По умолчанию следующий статус EXE

            // Разобрать метод адресации
            casex (i_data)

                8'bxxx_000_x1: cstate <= NDX;
                8'bxxx_010_x1,
                8'b1xx_000_x0: cstate <= EXE; // IMM
                8'bxxx_100_x1: cstate <= NDY;
                8'bxxx_110_x1: cstate <= ABY;
                8'bxxx_001_xx: cstate <= ZP;
                8'bxxx_011_xx,
                8'b001_000_00: cstate <= ABS;
                8'b10x_101_1x: cstate <= ZPY;
                8'bxxx_101_xx: cstate <= ZPX;
                8'b10x_111_1x: cstate <= ABY;
                8'bxxx_111_xx: cstate <= ABX;
                8'bxxx_100_00: cstate <= REL;
                default:       implied <= 1'b1; // ACC, IMP

            endcase

            // Все методы адресации разрешить читать из PPU, кроме STA
            casex (i_data) 8'b100_xxx_01, 8'b100_xx1_x0: read_en = 1'b0; endcase

        end

        // Indirect, X ($00,X)
        // -------------------------------------------------------------
        NDX+0: begin cstate <= cpunext; cursor <= i_data_x[7:0];   bus  <= 1'b1;    end
        NDX+1: begin cstate <= cpunext; cursor <= nextcursor[7:0]; tmp  <= i_data;  end
        NDX+2: begin cstate <= LAT;     cursor <= {i_data, tmp};   read <= read_en; end

        // Indirect, Y ($00),Y
        // -------------------------------------------------------------
        NDY+0: begin cstate <= cpunext;   cursor <= i_data;               bus <= 1'b1; end
        NDY+1: begin cstate <= cpunext;   cursor <= nextcursor[7:0];      tmp <= i_data_y[7:0]; cout <= i_data_y[8]; end
        NDY+2: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; read <= read_en; end

        // ZP, ZPX, ZPY
        // -------------------------------------------------------------
        ZP:    begin cstate <= EXE; cursor <= i_data;        bus <= 1'b1; read <= read_en; end
        ZPX:   begin cstate <= LAT; cursor <= i_data_x[7:0]; bus <= 1'b1; read <= read_en; end
        ZPY:   begin cstate <= LAT; cursor <= i_data_y[7:0]; bus <= 1'b1; read <= read_en; end

        // Absolute
        // -------------------------------------------------------------
        ABS+0: begin cstate <= cpunext; tmp <= i_data; pc <= pc + 1;  end
        ABS+1: begin // Либо отправляется на jmp (abs), либо используется как опкод

            if (opcode == JMP_ABS)
                 begin cstate <= INI; pc     <= {i_data, tmp}; end
            else begin cstate <= EXE; cursor <= {i_data, tmp}; bus <= 1'b1; read <= read_en; end

        end

        // Absolute,X
        // -------------------------------------------------------------
        ABX+0: begin cstate <= cpunext;   tmp    <= i_data_x[7:0];        pc  <= pc + 1; cout <= i_data_x[8]; end
        ABX+1: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; bus <= 1'b1;   read <= read_en;     end

        // Absolute,Y
        // -------------------------------------------------------------
        ABY+0: begin cstate <= cpunext;   tmp    <= i_data_y[7:0];        pc  <= pc + 1; cout <= i_data_y[8]; end
        ABY+1: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; bus <= 1'b1;   read <= read_en;     end

        // Задержка для симуляции тактов в 6502
        // -------------------------------------------------------------
        LAT:   cstate <= EXE;

        // Исполнение инструкции
        // -------------------------------------------------------------
        EXE: begin

            read <= 1'b0;           // Сброс такта чтения адреса

        end

    endcase


end

endmodule
