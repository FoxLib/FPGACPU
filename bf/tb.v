`timescale 10ns / 1ns

module tb;

// ---------------------------------------------------------------------

reg clock;
reg clock25;
always #0.5 clock   = ~clock;
always #1.5 clock25 = ~clock25;

initial begin clock = 1; clock25 = 0; #2000 $finish; end
initial begin $dumpfile("tb.vcd"); $dumpvars(0, tb); end

// ---------------------------------------------------------------------

reg  [ 3:0] prg;
reg  [ 7:0] mem;
reg  [ 3:0] prgmem[65536];
reg  [ 7:0] memory[65536];
wire [15:0] pc;                 // Адрес программы
wire [15:0] cursor;             // Адрес памяти
wire [ 7:0] out;                // Для записи
wire        we;
wire        print;              // Сигнал печати символа out
reg  [ 7:0] keyb = 0;

initial $readmemh("program.hex", prgmem, 16'h0000);
integer i;

initial for (i = 0; i < 1024; i++) memory[i] = 8'h00;

/* Формируется логика чтения и записи в память */
always @(posedge clock) begin

    prg <= prgmem[ pc ];
    mem <= memory[ cursor ];
    if (we) memory[ cursor ] <= out;

end

always @(posedge clock25) begin

    if (print) $display("Print: ", out);

end

// Модуль BF
bf bfunit(

    .clock      (clock25),
    .i_prg      (prg),
    .i_din      (mem),
    .keyb       (keyb),

    .pc         (pc),
    .cursor     (cursor),
    .out        (out),
    .we         (we),
    .print      (print)
);

endmodule
