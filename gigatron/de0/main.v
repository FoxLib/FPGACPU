`timescale 10ns / 1ns

module main;

// c17c
// ----
// 110 000 01 op=6, mode=0, bus=1

// ---------------------------------------------------------------------
reg clock;  always #0.5 clock   = ~clock;
reg clock6; always #2.0 clock6  = ~clock6; // 6.25 Mhz

initial begin clock = 0; clock6 = 0; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end

// ---------------------------------------------------------------------
// Памяти интерфейс
// ---------------------------------------------------------------------

reg  [15:0]  rom[65536]; // 64k, word
reg  [ 7:0]  ram[32768]; // 32k, byte

initial      $readmemh("rom.hex", rom, 0);
initial      $readmemh("ram.hex", ram, 0);

reg  [15:0] data_ir     = 0;
wire [15:0] address_pc;
wire [14:0] r_addr;
wire [14:0] w_addr;
reg  [ 7:0] i_data;

always @(posedge clock) begin

    // Чтение данных из ROM
    data_ir <= rom[ address_pc ];

    // Чтение и запись в RAM
    i_data <= ram[ r_addr ];
    if (o_we) ram[ w_addr ] <= o_data;

end

// ---------------------------------------------------------------------
wire [7:0]  inreg   = 8'hFF;
wire [ 7:0] o_data;
wire        o_we;
wire [ 7:0] outx;
wire [ 7:0] vga;
wire [ 7:0] ctrl;

gigatron u1
(
    // Исполнение программы
    .clock  (clock6),
    .rst_n  (1'b1),
    .pc     (address_pc),
    .ir     (data_ir),

    // Чтение и запись
    .r_addr (r_addr),
    .i_data (i_data),
    .w_addr (w_addr),
    .o_data (o_data),
    .o_we   (o_we),

    // Ввод-вывода
    .inreg  (inreg),
    .vga    (vga),
    .outx   (outx),
    .ctrl   (ctrl)
);

endmodule
