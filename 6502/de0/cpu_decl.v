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
    flag_carry = 0;

// ---------------------------------------------------------------------
// Регистры
// ---------------------------------------------------------------------

reg [ 7:0] A  = 8'h00;      // Аккумулятор
reg [ 7:0] X  = 8'h00;      // Индексный X
reg [ 7:0] Y  = 8'h00;      // Индексный Y
reg [ 7:0] S  = 8'h00;      // Стек
reg [ 7:0] P  = 8'h00;      // Флаги
reg [15:0] PC = 16'h0000;   // Регистр счетчика команд

// ---------------------------------------------------------------------
// Состояние процессора
// ---------------------------------------------------------------------
reg [ 7:0] opcode   = 0;
reg [ 3:0] cycle    = 0;
