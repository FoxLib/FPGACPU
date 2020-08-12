module cpu(

    input   wire        clock,
    output  wire [15:0] address,
    input   wire [ 7:0] i_data,
    output  reg  [ 7:0] o_data,
    output  reg         wren
);

`include "cpu_decl.v"
`include "cpu_alu.v"

endmodule
