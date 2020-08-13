parameter

    alu_ora = 4'b0000,
    alu_and = 4'b0001,
    alu_eor = 4'b0010,
    alu_adc = 4'b0011,
    alu_sta = 4'b0100,
    alu_lda = 4'b0101,
    alu_cmp = 4'b0110,
    alu_sbc = 4'b0111,

    alu_asl = 4'b1000,
    alu_rol = 4'b1001,
    alu_lsr = 4'b1010,
    alu_ror = 4'b1011,
    alu_bit = 4'b1100,
    alu_flg = 4'b1101,
    alu_dec = 4'b1110,
    alu_inc = 4'b1111;

parameter

    // Декодирование адреса
    INI  = 0,  NDX  = 1,  NDY  = 4,  ZP   = 7,  ZPX  = 8,  ZPY  = 9,
    ABS  = 10, ABX  = 12, ABY  = 14, LAT  = 16,

    // Исполнение кодов
    EXE  = 17, EXE2 = 18, EXE3 = 19, EXE4 = 20, EXE5 = 21, EXE6 = 22,
    REL  = 23;

parameter

    flag_carry = 0;

parameter

    JMP_ABS    = 8'h4C;

// ---------------------------------------------------------------------
// Регистры
// ---------------------------------------------------------------------

reg [ 7:0] A  = 8'h00;      // Аккумулятор
reg [ 7:0] X  = 8'h00;      // Индексный X
reg [ 7:0] Y  = 8'h00;      // Индексный Y
reg [ 7:0] S  = 8'h00;      // Стек
reg [ 7:0] P  = 8'h00;      // Флаги
reg [15:0] pc = 16'h0000;   // Регистр счетчика команд

// ---------------------------------------------------------------------
// Состояние процессора
// ---------------------------------------------------------------------
reg [ 7:0] opcode       = 0;
reg [ 4:0] cstate       = 0;
reg [ 3:0] cycle        = 0;
reg        implied      = 1'b0;

reg        read_en      = 1'b0;
reg        bus          = 1'b0;     // bus=0 (pc) bus=1 (cursor)
reg [15:0] cursor       = 0;

// ---------------------------------------------------------------------
// Алиасы
// ---------------------------------------------------------------------

wire [15:0] nextcursor  = cursor + 1'b1;
wire [ 4:0] cpunext     = cstate + 1'b1;

// ---------------------------------------------------------------------
// Вычисления адресации
// ---------------------------------------------------------------------

reg  [ 7:0] tmp;        // Временный регистр
reg         cout;       // Сохранение переноса

wire [ 8:0] i_data_x    = i_data + X;           // Для преиндексной адресации
wire [ 8:0] i_data_y    = i_data + Y;           // Для постиндексной адресации

// STA, INC|DEC, cout, сдвиговые, которые влияют на задержку
wire        is_incdec  = ({opcode[7:6], opcode[2:0]} == 5'b11_1_10) ||
                         ({opcode[7],   opcode[2:0]} == 4'b0__1_10);

wire        is_latency = cout | (opcode[7:5] == 3'b100) | is_incdec;
wire [4:0]  lat_state  = is_latency ? LAT : EXE;
