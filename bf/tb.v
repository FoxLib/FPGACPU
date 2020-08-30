`timescale 10ns / 1ns

module tb;

// ---------------------------------------------------------------------

reg         clk;
always #0.5 clk = ~clk;

initial begin clk = 1; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end

// ---------------------------------------------------------------------

reg  [ 7:0] prg;
reg  [ 7:0] mem;
reg  [ 3:0] prgmem[65536];
reg  [ 7:0] memory[65536];
wire [15:0] pc;                 // Адрес программы
wire [15:0] cursor;             // Адрес памяти
wire [ 7:0] out;                // Для записи
wire        we;

initial $readmemh("program.hex", prgmem, 16'h0000);

/* Формируется логика чтения и записи в память */
always @(posedge clk) begin

    prg <= prgmem[ pc ];
    mem <= memory[ cursor ];
    if (we) memory[ cursor ] <= out;

end

endmodule
