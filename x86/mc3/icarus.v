`timescale 10ns / 1ns
module main;

// ---------------------------------------------------------------------
reg clk;
reg clk25;
always #0.5 clk   = ~clk;
always #1.5 clk25 = ~clk25;

initial begin clk = 1; clk25 = 0; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end

// ---------------------------------------------------------------------
// Мини-контроллер памяти
// ---------------------------------------------------------------------

wire [19:0] address;
reg  [ 7:0] data;
wire [ 7:0] out;
wire        wren;

reg  [ 7:0] allmem[1048576];

always @(posedge clk) begin

    data <= allmem[address];
    if (wren) allmem[address] <= out;

end

// ---------------------------------------------------------------------

core IntelCore
(
    .clock      (clk25),
    .address    (address),
    .data       (out),
    .out        (out),
    .wren       (wren)
);

endmodule
