// ---------------------------------------------------------------------
localparam

    sub_opcode      = 0,    // Базовый опкод
    sub_extended    = 1,    // Считывание расширенного кода
    sub_modrm       = 2,    // Прочитать и разобрать modrm
    sub_exec        = 3,    // Исполнить инструкции
    sub_wb          = 4;    // Обратная запись в modrm

localparam

    seg_es = 0, reg_ax = 0, reg_sp = 4, reg_al = 0, reg_ah = 4,
    seg_cs = 1, reg_cx = 1, reg_bp = 5, reg_cl = 1, reg_ch = 5,
    seg_ss = 2, reg_dx = 2, reg_si = 6, reg_dl = 2, reg_dh = 6,
    seg_ds = 3, reg_bx = 3, reg_di = 7, reg_bl = 3, reg_bh = 7;

localparam

    alu_add = 0, alu_and = 4,
    alu_or  = 1, alu_sub = 5,
    alu_adc = 2, alu_xor = 6,
    alu_sbb = 3, alu_cmp = 7;

// ---------------------------------------------------------------------
initial begin

    out       = 8'h00;
    wren      = 1'b0;

    s[seg_es] = 16'h1122;
    s[seg_cs] = 16'h0000;
    s[seg_ss] = 16'hF123;
    s[seg_ds] = 16'h0000;

    r[reg_ax] = 16'h1234; r[reg_sp] = 16'hEFAE;
    r[reg_cx] = 16'h2233; r[reg_bp] = 16'hBABA;
    r[reg_dx] = 16'h6677; r[reg_si] = 16'hBEBE;
    r[reg_bx] = 16'h4455; r[reg_di] = 16'hCACA;

end

// ---------------------------------------------------------------------
reg [ 2:0]  sub     = 0;        // Текущая исполняемая процедура
reg [ 2:0]  subret  = 0;        // RETURN для процедуры
reg [ 2:0]  fn      = 0;        // Субфункция #1
reg [ 2:0]  fn2     = 0;        // Субфункция #2
reg [ 7:0]  opcode  = 0;
reg         swi     = 1'b0;     // =1 Используется эффективный [seg:eff]
reg         override = 1'b0;
reg        _override = 1'b0;
reg [ 1:0]  rep     = 0;        // Бит 1: Есть ли REP: префикс
reg [ 1:0] _rep     = 0;        // Бит 0: 0=RepNZ, 1=RepZ
reg [ 3:0]  alu     = 16'h0;    // Номер АЛУ-операции
reg [15:0]  op1     = 16'h0;    // Левый операнд
reg [15:0]  op2     = 16'h0;    // Правый операнд
reg         bit16   = 0;        // Используются 16-битные операнды
reg         dir     = 0;        // 0=r/m,reg | 1=reg,r/m
reg [ 7:0]  modrm   = 8'h00;    // Сохраненный байт ModRM
reg [15:0]  wb      = 16'h0000; // Значение для обратной записи в modrm

// Эффективный адрес
reg [15:0]  seg = 0;
reg [15:0] _seg = 16'h0000;
reg [15:0]  eff = 0;
// ---------------------------------------------------------------------
reg [15:0]  r[8];               // Регистры общего назначения
reg [15:0]  s[4];               // Сегменты es: cs: ss: es:
reg [15:0]  ip    = 16'h8000;   // "PostBios" загрузка
reg [11:0]  flags = 12'b0000_0000_0000;
// ---------------------------------------------------------------------
wire [2:0]  data53  =   data[5:3];
wire [2:0]  data20  =   data[2:0];
wire [15:0] rdata43 = r[data[4:3]];
wire [15:0] rdata10 = r[data[1:0]];
// ---------------------------------------------------------------------
assign      address = swi ? {seg, 4'h0} + eff : {s[seg_cs], 4'h0} + ip;

// ---------------------------------------------------------------------
// Объявление арифметико-логического устройства
// ---------------------------------------------------------------------

wire [15:0] result;
wire [11:0] flags_out;

alu ArithLogicUnit
(
    .alu    (alu),
    .op1    (op1),
    .op2    (op2),
    .flags  (flags),
    .bit16  (bit16),
    .result (result),
    .flags_out (flags_out)
);
