parameter
    SEG_ES = 0, REG_AX = 0, REG_SP = 4,
    SEG_CS = 1, REG_CX = 1, REG_BP = 5,
    SEG_SS = 2, REG_DX = 2, REG_SI = 6,
    SEG_DS = 3, REG_BX = 3, REG_DI = 7;

// Инициализация регистров
// ---------------------------------------------------------------------

reg [15:0] r16[8];
reg [15:0] seg[6];
reg [11:0] flags;
reg [15:0] ip;

initial begin

    r16[REG_AX] = 16'h0000;
    r16[REG_CX] = 16'h0000;
    r16[REG_DX] = 16'h0000;
    r16[REG_BX] = 16'h0000;
    r16[REG_SP] = 16'h0000;
    r16[REG_BP] = 16'h0000;
    r16[REG_SI] = 16'h0000;
    r16[REG_DI] = 16'h0000;

    seg[SEG_ES] = 16'h0000;
    seg[SEG_CS] = 16'h0000;
    seg[SEG_SS] = 16'h0000;
    seg[SEG_DS] = 16'h0000;

    ip     = 16'h0000;
    flags  = 16'b0000_0000_0010;
    //           ODIT SZ-A -P-C

end

// Первоначальная инициализация
// ---------------------------------------------------------------------

initial begin

    segment_id = SEG_DS;
    bus = 0;
    fn  = 0;
    cn  = 0;

end

// Состояние процессора в данный момент
// ---------------------------------------------------------------------

reg [ 8:0]  opcode;
reg [ 3:0]  fn;                 // Главное состояние процессора
reg [ 3:0]  cn;                 // Номер такта процедуры
reg         segment_px;         // Наличие префикса в инструкции
reg [ 2:0]  segment_id;         // Номер выбранного сегмента
reg [15:0]  ea;                 // Эффективный адрес
reg         bus;                // 0 => CS:IP, 1 => segment_id:ea
reg [ 1:0]  rep;                // REP[0] = NZ|Z; REP[1] = наличие префикса
reg [ 7:0]  modrm;              // Сохраненный байт modrm
reg [15:0]  op1;                // Операнд 1
reg [15:0]  op2;                // Операнд 2
reg         i_dir;              // 0=rm, r; 1=r, rm
reg         i_size;             // 0=8 bit; 1=16 bit
