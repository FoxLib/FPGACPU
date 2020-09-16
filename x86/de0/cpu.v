module cpu
(
    // Основной контур для процессора
    input   wire        clock,              // 25 mhz
    output  wire [19:0] address,
    input   wire [ 7:0] i_data,             // i_data = ram[address]
    output  reg  [ 7:0] o_data,
    output  reg         we
);

`include "cpu_decl.v"
`include "cpu_regs.v"

assign address = 0;

endmodule

