parameter
    SEG_ES = 0, SEG_CS = 1, SEG_SS = 2, SEG_DS = 3, SEG_FS = 4, SEG_GS = 5;

// Инициализация регистров
// ---------------------------------------------------------------------

reg [31:0] r32[8];
reg [15:0] s16[6];
reg [31:0] ip;
reg [32:0] eflags;
reg [63:0] segment[6];       // Сегментные регистры для p-mode

initial begin

    r32[0] = 32'h00_00_00_00; // EAX
    r32[1] = 32'h00_00_00_00; // ECX
    r32[2] = 32'h00_00_00_00; // EDX
    r32[3] = 32'h00_00_00_00; // EBX
    r32[4] = 32'h00_00_00_00; // ESP
    r32[5] = 32'h00_00_00_00; // EBP
    r32[6] = 32'h00_00_00_00; // ESI
    r32[7] = 32'h00_00_00_00; // EDI

    s16[0] = 16'h0000; // ES
    s16[1] = 16'h0000; // CS
    s16[2] = 16'h0000; // SS
    s16[3] = 16'h0000; // DS
    s16[4] = 16'h0000; // FS
    s16[5] = 16'h0000; // GS

    ip     = 32'h0000_0000;

    //                       IV V     NIO
    //                       DP FAVR 0TPL ODIT SZ0A 0P1C
    eflags = 32'b0000_0000_0010_0000_0000_0000_0000_0010;

end

// Первоначальная инициализация
// ---------------------------------------------------------------------

initial begin

    pmode           = 1'b0;
    mstate          = 1'b0;
    cycle           = 1'b0;
    o_data          = 1'b0;
    opcode          = 1'b0;
    seg_id          = 1'b0;
    seg_pre         = 1'b0;
    swi             = 1'b0;
    adsize          = 1'b0;
    opsize          = 1'b0;
    def_opsize      = 1'b0;     // 16 bit
    def_adsize      = 1'b0;     // 16 bit
    we              = 1'b0;

end

// Состояние процессора в данный момент
// ---------------------------------------------------------------------

reg         pmode;
reg [ 8:0]  opcode;
reg [ 2:0]  mstate;             // Главное состояние процессора
reg [ 4:0]  cycle;              // Цикл выполнения инструкции
reg         seg_pre;            // Наличие префикса в инструкции
reg [ 2:0]  seg_id;             // Номер выбранного сегмента
reg [31:0]  ea;                 // Эффективный адрес
reg         swi;                // 0 => CS:EIP, 1 => seg:ea
reg [ 1:0]  rep;                // REP[0] = NZ|Z; REP[1] = наличие префикса
reg         opsize;
reg         adsize;
reg         def_opsize;         // operand size (16/23)
reg         def_adsize;         // address size (16/23)

// Различные вычисления
// ---------------------------------------------------------------------

// IP меняется в зависимости от режима работы процессора в данный момент
wire [31:0] ipnext = ip + 1;

