module cpu(

    input wire [31:0] in,
    output reg [31:0] address,
    output reg [31:0] out,
    output reg        we
);

wire [31:0] in;
wire [4:0]  cntlsl;

// Сдвиг налево LSL
wire [31:0] lsl4 = cntlsl[4] ? {in  [15:0], 16'h0000} : in;
wire [31:0] lsl3 = cntlsl[3] ? {lsl4[23:0],    8'h00} : lsl4;
wire [31:0] lsl2 = cntlsl[2] ? {lsl3[27:0],     4'h0} : lsl3;
wire [31:0] lsl1 = cntlsl[1] ? {lsl2[29:0],     2'h0} : lsl2;
wire [31:0] lsl  = cntlsl[0] ? {lsl1[30:0],     1'h0} : lsl1;

// Перенос carry
wire lsc4 = cntlsl[4] ? in[16]   : in[31];
wire lsc3 = cntlsl[3] ? lsl4[24] : lsc4;
wire lsc2 = cntlsl[2] ? lsl3[28] : lsc3;
wire lsc1 = cntlsl[1] ? lsl2[30] : lsc2;
wire lsc  = cntlsl[1] ? lsl1[31] : lsc1;

endmodule
