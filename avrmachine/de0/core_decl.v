// ---------------------------------------------------------------------
// Декларации
// ---------------------------------------------------------------------

`define SPDEC 1
`define SPINC 2

initial begin

    pc = 0; address = 0; wb = 0; w = 0; vmode = 0;

    sdram_address = 0;
    sdram_control = 0;
    sdram_o_data  = 0;

    cursor_x = 0;
    cursor_y = 0;
    spi_cmd  = 0;
    spi_out  = 0;
    spi_sent = 0;
    bank     = 0;

    // Low
    r[0] = 8'h00; r[4] = 8'h00; r[8]  = 8'h00; r[12] = 8'h01;
    r[1] = 8'h00; r[5] = 8'h00; r[9]  = 8'h00; r[13] = 8'h00;
    r[2] = 8'h00; r[6] = 8'h00; r[10] = 8'h00; r[14] = 8'h00;
    r[3] = 8'h00; r[7] = 8'h00; r[11] = 8'h00; r[15] = 8'h00;

    // High
    r[16] = 8'h00; r[20] = 8'h00; r[24] = 8'h00; r[28] = 8'h00;
    r[17] = 8'h00; r[21] = 8'h00; r[25] = 8'h00; r[29] = 8'h00;
    r[18] = 8'h00; r[22] = 8'h00; r[26] = 8'h00; r[30] = 8'h05;
    r[19] = 8'h00; r[23] = 8'h00; r[27] = 8'h00; r[31] = 8'hFA;

end

// ---------------------------------------------------------------------
// Регистры процессора, в том числе системные
// ---------------------------------------------------------------------

// Регистры
reg [ 7:0]  r[32];                      // Регистры
reg [ 1:0]  tstate  = 0;                // Машинное состояние
reg [15:0]  latch   = 0;                // Записанный опкод
reg [15:0]  pclatch = 0;                // Для LPM / SPM
reg [15:0]  sp      = 16'hEFFF;         // Stack Pointer
reg [ 7:0]  sreg    = 8'b0000_0000;     // Status Register
reg [ 4:0]  alu     = 0;                // Режим работы АЛУ
reg         locked  = 1'b0;             // Блокировать процессор, пока SPI занят
reg         spi_proc = 0;               // Процессор сейчас работает с SPI

// Команды на обратном фронте
reg         reg_w   = 0;                // Писать регистр
reg [ 4:0]  reg_id  = 0;                // В какой регистр писать
reg         sreg_w  = 0;                // Писать в SREG из АЛУ
reg [ 1:0]  sp_mth  = 0;                // Увеличение или уменьшение стека
reg         aread   = 0;                // Признак чтения из памяти
reg         kbit    = 0;                // Прочитал ли бит KBHIT

// 16 битные регистры
reg         reg_ww  = 0;                // Писать в X,Y,Z
reg         reg_ws  = 0;                // =1 Источник АЛУ; =0 Источник регистр `wb2`
reg [ 1:0]  reg_idw = 0;                // Номер 16-битного регистра
reg [15:0]  wb2     = 0;                // Что писать в X,Y,Z
reg [ 7:0]  rampz   = 0;                // Верхняя память для E-функции

// Провода
wire [15:0] opcode = tstate ? latch : ir;
wire [15:0] X   = {r[27], r[26]};
wire [15:0] Y   = {r[29], r[28]};
wire [15:0] Z   = {r[31], r[30]};
wire [15:0] Xm  = X - 1;
wire [15:0] Xp  = X + 1;
wire [15:0] Ym  = Y - 1;
wire [15:0] Yp  = Y + 1;
wire [15:0] Zm  = Z - 1;
wire [15:0] Zp  = Z + 1;
wire [ 5:0] q   = {opcode[13], opcode[11:10], opcode[2:0]};
wire [ 4:0] rd  =  opcode[8:4];
wire [ 4:0] rr  = {opcode[9], opcode[3:0]};
wire [ 4:0] rdi = {1'b1, opcode[7:4]};
wire [ 4:0] rri = {1'b1, opcode[3:0]};
wire [ 7:0] K   = {opcode[11:8], opcode[3:0]};

reg         skip_instr = 0;
wire [15:0] pcnext  = pc + 1;
wire [15:0] pcnext2 = pc + 2;
wire        is_call = {opcode[14], opcode[3:1]} == 4'b0111;

// Текущий статус
assign      kb_hit      = kb_trigger ^ kb_tr;
reg         kb_trigger  = 1'b0;

// Арифметико-логическое устройство
reg  [ 7:0] op1;
reg  [ 7:0] op2;
wire [ 7:0] alu_res;
wire [ 7:0] alu_sreg;
reg  [15:0] op1w;
wire [15:0] resw;

alu UnitALU
(
    alu,
    op1, op2, sreg,
    alu_res, alu_sreg,
    op1w, resw
);
