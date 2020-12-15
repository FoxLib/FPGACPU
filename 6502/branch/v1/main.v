`timescale 10ns / 1ns

/*
 * Эмулятор КР580*** какого-то там компа
 */

module main;

// ---------------------------------------------------------------------

reg clk;
reg clk25;
always #0.5 clk   = ~clk;
always #1.5 clk25 = ~clk25;

initial begin clk = 1; clk25 = 0; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end

// ---------------------------------------------------------------------

reg  [ 7:0] memory[65536];
reg  [ 7:0] i_data;
wire [15:0] o_address;
wire [ 7:0] o_data;
wire        wren;

// Традиционно загрузка сюда ROM
initial $readmemh("rom.hex", memory, 16'h8000);

/* Формируется логика чтения и записи в память */
always @(posedge clk) begin

    i_data <= memory[ o_address ];
    if (wren) memory[ o_address ] <= o_data;

end

// ---------------------------------------------------------------------

cpu CPU6502(

    .clock      (clk25),
    .address    (o_address),
    .i_data     (i_data),
    .o_data     (o_data),
    .wren       (wren)
);


endmodule
