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

        // Разбор опкода и получение операнда из памяти
        `include "cpu_addr.v"

        // Исполнение инструкции
        EXE: begin

            read <= 1'b0;       // Сброс такта чтения адреса
            bus  <= 1'b0;       // Переключить снова на PC
            cstate <= 0;

            // Получен IMM
            casex (opcode) 8'bxxx_010_x1, 8'b1xx_000_x0: pc <= pc + 1; endcase

            // Исполнение первого такта опкода
            casex (opcode)

                8'b100x_xx01: /* STx */ begin wren <= 1'b0;  end
                8'b110x_xx01: /* CMP */ begin P <= alu_flag; end
                8'b101x_1010: /* TAX, TSX */ begin P <= alu_flag; X <= alu_res[7:0]; end
                8'b1010_0010, /* LDX */
                8'b101x_x110: /* LDX */ begin P <= alu_flag; X <= alu_res[7:0]; end
                8'bxxxx_xx01: /* ALU */ begin P <= alu_flag; A <= alu_res[7:0]; end

            endcase

        end

    endcase

end

endmodule
