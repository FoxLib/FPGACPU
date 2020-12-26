/**
 * @desc Процессор, основанный на анализе и повторе js-эмулятора Gigatron
 * @url  https://gigatron.io/
 */

module gigatron
(
    input   wire        clock,
    input   wire        rst_n,

    // Обращение в ROM
    output  reg  [15:0] pc,
    input   wire [15:0] rom_i,

    // Чтение и запись
    output  reg  [15:0] addr_r,
    output  reg  [15:0] addr_w,
    input   wire [ 7:0] data_i,
    output  reg  [ 7:0] data_o,
    output  reg         we,

    // Порты ввода-вывода
    input   wire [ 7:0] inreg,
    output  reg  [ 7:0] vga,
    output  reg  [ 7:0] outx,

    // 76543210
    // ^^^^^^^^
    // |||||||`-- SCLK
    // ||||||`--- Not connected
    // |||||`---- /SS0
    // ||||`----- /SS1
    // |||`------ /SS2
    // ||`------- /SS3
    // |`-------- B0
    // `--------- B1 (Memory Bank)
    output  reg  [ 7:0] ctrl
);

initial begin

    pc      = 0;
    we      = 0;
    addr_r  = 0;
    addr_w  = 0;
    data_o  = 0;
    vga     = 0;
    outx    = 0;
    ctrl    = 0;

end

// Регистры
// ---------------------------------------------------------------------
reg  [ 7:0] ac  = 0;
reg  [ 7:0] x   = 0;
reg  [ 7:0] y   = 0;
reg  [15:0] ir  = 0;

// Декодирование IR
// ---------------------------------------------------------------------
wire [ 7:0] op      = ir[15:13]; // 3 Операция
wire [ 7:0] mode    = ir[12:10]; // 3 Режим
wire [ 7:0] bus     = ir[ 9:8];  // 2 Шина
wire [ 7:0] d       = ir[ 7:0];  // 8 Данные

// Вычисления
// ---------------------------------------------------------------------
wire [ 7:0] zac     = {~ac[7], ac[6:0]};
wire [15:0] pcinc   = pc + 1;

endmodule
