`timescale 10ns / 1ns
module tb;
// ---------------------------------------------------------------------
reg clock;
reg clock_25;
reg clock_50;

always #0.5 clock    = ~clock;
always #1.0 clock_50 = ~clock_50;
always #1.5 clock_25 = ~clock_25;

initial begin clock = 1; clock_25 = 0; clock_50 = 0; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end
// ---------------------------------------------------------------------

reg  [ 7:0] memory[65536];
reg  [ 7:0] i_data;
wire [15:0] o_address;
wire [ 7:0] o_data;
wire        wren;

// Традиционно загрузка сюда ROM
initial $readmemh("rom.hex", memory, 16'h8000);

/* Формируется логика чтения и записи в память */
always @(posedge clock) begin

    i_data <= memory[ o_address ];
    if (wren) memory[ o_address ] <= o_data;

end

// ---------------------------------------------------------------------
cpu CPU6502(

    .clock      (clock_25),
    .address    (o_address),
    .i_data     (i_data),
    .o_data     (o_data),
    .wren       (wren)
);

endmodule
