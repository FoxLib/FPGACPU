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

            read <= 1'b0;           // Сброс такта чтения адреса

        end

    endcase


end

endmodule
