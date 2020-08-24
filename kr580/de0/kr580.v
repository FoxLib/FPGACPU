module kr580(

    /* Шина данных */
    input   wire         pin_clk,
    input   wire [ 7:0]  pin_i,
    output  wire [15:0]  pin_a,         // Указатель на адрес
    output  reg          pin_enw,       // Разрешить запись (высокий уровень)
    output  reg  [ 7:0]  pin_o,

    /* Порты */
    output  reg  [ 7:0]  pin_pa,
    input   wire [ 7:0]  pin_pi,
    output  reg  [ 7:0]  pin_po,
    output  reg          pin_pw,

    /* Interrupt */
    input   wire         pin_intr

);

// Базовый набор
`define ALU_ADD     4'h0
`define ALU_ADC     4'h1
`define ALU_SUB     4'h2
`define ALU_SBC     4'h3
`define ALU_AND     4'h4
`define ALU_XOR     4'h5
`define ALU_OR      4'h6
`define ALU_CP      4'h7

// Дополнительный набор
`define ALU_RLC     4'h8
`define ALU_RRC     4'h9
`define ALU_RL      4'hA
`define ALU_RR      4'hB
`define ALU_DAA     4'hC
`define ALU_CPL     4'hD
`define ALU_SCF     4'hE
`define ALU_CCF     4'hF

`define CARRY       0
`define PARITY      2
`define AUX         4
`define ZERO        6
`define SIGN        7

`define REG_B       0
`define REG_C       1
`define REG_D       2
`define REG_E       3
`define REG_H       4
`define REG_L       5
`define REG_F       6
`define REG_A       7

`define REG_BC      0
`define REG_DE      1
`define REG_HL      2
`define REG_SP      3

`define FALSE       1'b0
`define TRUE        1'b1

initial begin

    pin_enw = 0;
    pin_o   = 0;
    pin_pa  = 0;
    pin_po  = 0;

end

/* Указатель на необходимые данные */
assign pin_a = alt_a ? cursor : pc;

/* Управляющие регистры */
reg  [ 3:0] t       = 0;        // Это t-state
reg         halt    = 0;        // Процессор остановлен
reg         ei      = 0;        // Enabled Interrupt
reg         ei_     = 0;        // Это необходимо для EI+RET конструкции
reg  [15:0] cursor  = 0;
reg         alt_a   = 1'b0;     // =0 pc  =1 cursor

/* Регистры общего назначения */
reg  [15:0] bc = 16'h0000;
reg  [15:0] de = 16'h0000;
reg  [15:0] hl = 16'h0000;
reg  [15:0] pc = 16'h0000;
reg  [15:0] sp = 16'h0000;
reg  [ 7:0] a  = 8'h00;
reg  [ 7:0] f  = 8'b01000000;
                //  SZ A P C

/* Сохраненный опкод */
wire [ 7:0] opcode          = t ? opcode_latch : (pend_int ? 8'hFF : pin_i);
reg  [ 7:0] opcode_latch    = 8'h00;
reg         prev_intr       = 1'b0;
reg         pend_int        = 1'b0;

/* Управление записью в регистры */
reg         reg_b = 1'b0;       // Сигнал на запись 8 битного регистра
reg         reg_w = 1'b0;       // Сигнал на запись 16 битного регистра (reg_u:reg_v)
reg  [ 2:0] reg_n = 3'h0;       // Номер регистра
reg  [ 7:0] reg_l = 8'h00;      // Что писать
reg  [ 7:0] reg_u = 8'h00;      // Что писать
reg  [ 7:0] reg_r8;             // reg_r8  = regs8 [ reg_n ]
reg  [15:0] reg_r16;            // reg_r16 = regs16[ reg_n ]
reg         ex_de_hl;

/* Определение условий */
wire        reg_hl  = (reg_n == 3'b110);
wire [15:0] signext = {{8{pin_i[7]}}, pin_i[7:0]};
wire [3:0]  cc      = {f[`CARRY], ~f[`CARRY], f[`ZERO], ~f[`ZERO]};
wire        ccc     = (opcode[5:4] == 2'b00) & (f[`ZERO]   == opcode[3]) | // NZ, Z,
                      (opcode[5:4] == 2'b01) & (f[`CARRY]  == opcode[3]) | // NC, C,
                      (opcode[5:4] == 2'b10) & (f[`PARITY] == opcode[3]) | // PO, PE
                      (opcode[5:4] == 2'b11) & (f[`SIGN]   == opcode[3]) | // P, M
                       opcode == 8'b11_001_001 | // RET
                       opcode == 8'b11_000_011 | // JP
                       opcode == 8'b11_001_101;  // CALL

/* Арифметическое-логическое устройство */
reg  [ 3:0] alu_m = 0;
reg  [ 8:0] alu_r;
reg  [ 7:0] alu_f;
reg  [ 7:0] op1 = 0;        // Первый операнд для АЛУ
reg  [ 7:0] op2 = 0;        // Второй операнд для АЛУ

/* Исполнение инструкции */
always @(posedge pin_clk) begin

    /* Определение позитивного фронта intr */
    prev_intr <= pin_intr;

    /* Получение запроса внешнего Interrupt */
    if ({prev_intr, pin_intr} == 2'b01) begin

        pend_int <= ei;
        pc       <= pc + (ei & halt);

    end

    /* Исполнение опкодов */
    else begin

        /* Запись опкода на будущее */
        if (t == 0) begin

            opcode_latch <= pend_int ? 8'hFF : pin_i; /* RST $38 */
            pend_int     <= 1'b0;

            if (pend_int) // Отключить другие прерывания
            begin ei <= 0; ei_ <= 0; end
            else  ei <= ei_;

        end

        /* Подготовка управляющих сигналов */
        alt_a    <= 1'b0;
        reg_b    <= 1'b0;
        reg_w    <= 1'b0;
        pin_enw  <= 1'b0;
        pin_pw   <= 1'b0;
        halt     <= 1'b0;
        ex_de_hl <= 1'b0;

        casex (opcode)

            // 1 NOP
            8'b00_000_000: pc <= pc + 1;

            // 1/2 DJNZ *
            8'b00_010_000: case (t)

                0: begin

                    reg_b <= `TRUE;
                    reg_n <= `REG_B;
                    reg_l <= bc[15:8] - 1;

                    if (bc[15:8] == 8'h01) pc <= pc + 2;
                    else begin t <= 1;     pc <= pc + 1; end

                end
                1: begin t <= 0; pc <= pc + 1 + signext; end

            endcase

            // 2 JR *
            8'b00_011_000: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 0; pc <= pc + 1 + signext; end

            endcase

            // 1|2 JR cc, *
            8'b00_1xx_000: case (t)

                0: begin if (cc[ opcode[4:3] ]) begin pc <= pc + 1; t <= 1; end
                                           else begin pc <= pc + 2; end end
                1: begin t <= 0; pc <= pc + 1 + signext; end

            endcase

            // 3 LD r, i16
            8'b00_xx0_001: case (t)

                0: begin pc <= pc + 1; t <= 1; reg_n <= opcode[5:4]; end
                1: begin pc <= pc + 1; t <= 2; reg_l <= pin_i; end
                2: begin pc <= pc + 1; t <= 0; reg_u <= pin_i; reg_w <= `TRUE; end

            endcase

            // 4 ADD HL, r
            8'b00_xx1_001: case (t)

                0: begin t <= 1;
                    reg_n     <= {opcode[5:4], 1'b1};
                    pc        <= pc + 1;
                end
                1: begin t <= 2;
                    reg_n     <= {opcode[5:4], 1'b0};
                    op1       <= hl[ 7:0];
                    op2       <= reg_r8;
                    alu_m     <= `ALU_ADD;
                end
                2: begin t <= 3;
                    op1       <= hl[15:8];
                    op2       <= reg_r8;
                    reg_n     <= `REG_L;
                    reg_b     <= `TRUE;
                    reg_l     <= alu_r[7:0];
                    f[`CARRY] <= alu_f[`CARRY];
                    alu_m     <= `ALU_ADC;
                end
                3: begin t <= 0;
                    reg_n     <= `REG_H;
                    reg_l     <= alu_r[7:0];
                    reg_b     <= `TRUE;
                    f[`AUX]   <= alu_f[`AUX];
                    f[`CARRY] <= alu_f[`CARRY];
                    f[`SIGN]  <= alu_f[`SIGN];
                end

            endcase

            // 2 LD (r16), A
            8'b00_0x0_010: case (t)

                0: begin t <= 1; pc <= pc + 1; cursor <= opcode[4] ? de : bc; alt_a <= 1; pin_o <= a; pin_enw <= 1; end
                1: begin t <= 0; alt_a <= 0; end

            endcase

            // 2 LD A, (r16)
            8'b00_0x1_010: case (t)

                0: begin t <= 1; pc <= pc + 1; cursor <= opcode[4] ? de : bc; alt_a <= 1; end
                1: begin t <= 0; reg_b <= 1; reg_l <= pin_i; reg_n <= `REG_A; end

            endcase

            /* 4 LD (**), HL */
            8'b00_100_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[7:0] <= pin_i; end
                2: begin t <= 3; pin_enw <= 1; alt_a <= 1; pin_o <= hl[ 7:0]; cursor[15:8] <= pin_i; end
                3: begin t <= 4; pin_enw <= 1; alt_a <= 1; pin_o <= hl[15:8]; cursor <= cursor + 1;  end
                4: begin t <= 0; pc <= pc + 1; end

            endcase

            /* 5 LD HL, (**) */
            8'b00_101_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[ 7:0] <= pin_i; end
                2: begin t <= 3; pc <= pc + 1; cursor[15:8] <= pin_i; alt_a <= 1; end
                3: begin t <= 4; reg_n <= `REG_L; reg_b <= 1; reg_l <= pin_i; alt_a <= 1; cursor <= cursor + 1; end
                4: begin t <= 0; reg_n <= `REG_H; reg_b <= 1; reg_l <= pin_i; end

            endcase

            /* 4 LD (**), A */
            8'b00_110_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[7:0] <= pin_i; end
                2: begin t <= 3; pin_enw <= 1; alt_a <= 1; pin_o <= a[7:0]; cursor[15:8] <= pin_i; end
                3: begin t <= 0; pc <= pc + 1; end

            endcase

            /* 4 LD A, (**) */
            8'b00_111_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[ 7:0] <= pin_i; end
                2: begin t <= 3; pc <= pc + 1; cursor[15:8] <= pin_i; alt_a <= 1; end
                3: begin t <= 0; reg_b <= 1; reg_n <= `REG_A; reg_l <= pin_i; end

            endcase

            /* 2 INC r16 */
            8'b00_xx0_011: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; end
                1: begin t <= 0; {reg_u, reg_l} <= reg_r16 + 1; reg_w <= 1; end

            endcase

            /* 2 DEC r16 */
            8'b00_xx1_011: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; end
                1: begin t <= 0; {reg_u, reg_l} <= reg_r16 - 1; reg_w <= 1; end

            endcase

            /* 4 INC r8 */
            /* 4 DEC r8 */
            8'b00_xxx_10x: case (t)

                0: begin t <= 1;
                    pc     <= pc + 1;
                    reg_n  <= opcode[5:3];
                    cursor <= hl;
                    alt_a  <= 1; end
                1: begin t <= 2;
                    op1    <= reg_hl ? pin_i : reg_r8;
                    op2    <= 1;
                    alu_m  <= opcode[0] ? `ALU_SUB : `ALU_ADD; end
                2: begin t <= 3;
                    pin_enw <=  reg_hl;
                    reg_b   <= ~reg_hl;
                    reg_l   <= alu_r;
                    pin_o   <= alu_r;
                    f       <= alu_f;
                    alt_a   <= 1; end
                3: begin t <= 0; end

            endcase

            /* 3 LD r, i8 */
            8'b00_xxx_110: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:3]; cursor <= hl; end
                1: begin t <= 2; pc <= pc + 1; reg_b <= ~reg_hl; pin_enw <= reg_hl; reg_l <= pin_i; pin_o <= pin_i; alt_a <= 1; end
                2: begin t <= 0; end

            endcase

            /* 2 RLCA, RRCA, RLA, RRA, DAA, CPL, SCF, CCF */
            8'b00_xxx_111: case (t)

                0: begin t <= 1; pc <= pc + 1; op1 <= a; alu_m <= {1'b1, opcode[5:3]}; end
                1: begin t <= 0; reg_b <= 1; reg_l <= alu_r; reg_n <= `REG_A; f <= alu_f; end

            endcase

            /* 4 LD r, r */
            8'b01_110_110: halt <= 1;
            8'b01_xxx_xxx: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[2:0]; alt_a <= 1; cursor <= hl; end
                1: begin t <= 2; reg_l <= reg_hl ? pin_i : reg_r8; reg_n <= opcode[5:3]; end
                2: begin t <= 3; reg_b <= ~reg_hl; pin_enw <= reg_hl; pin_o <= reg_l; alt_a <= 1; end
                3: begin t <= 0; end

            endcase

            /* 3 <alu> A, r */
            8'b10_xxx_xxx: case (t)

                0: begin t <= 1; op1   <= a; pc <= pc + 1; reg_n <= opcode[2:0]; alt_a <= 1; cursor <= hl; end
                1: begin t <= 2; op2   <= reg_hl ? pin_i : reg_r8; alu_m <= opcode[5:3]; end
                2: begin t <= 0; reg_b <= (alu_m != 3'b111); reg_n <= `REG_A; reg_l <= alu_r; f <= alu_f; end

            endcase

            /* 2/3 RET c | RET */
            8'b11_001_001,
            8'b11_xxx_000: case (t)

                0: begin t <= ccc; alt_a <= ccc; pc <= pc + 1; cursor <= sp; end
                1: begin t <= 2; pc[ 7:0] <= pin_i; alt_a <= 1; cursor <= cursor + 1; end
                2: begin t <= 0; pc[15:8] <= pin_i; {reg_u, reg_l} <= cursor + 1; reg_n <= `REG_SP; reg_w <= 1; end

            endcase

            /* 4 POP r16 */
            8'b11_xx0_001: case (t)

                0: begin t <= 1; cursor <= sp;         alt_a <= 1;  pc    <= pc + 1; end
                1: begin t <= 2; cursor <= cursor + 1; alt_a <= 1;  reg_l <= pin_i; end
                2: begin t <= 3; cursor <= cursor + 1;              reg_u <= pin_i;

                         if (opcode[5:4] == 2'b11) /* POP AF */
                              begin reg_n <= `REG_A;      reg_b <= 1; reg_l <= pin_i; f <= reg_l; end
                         else begin reg_n <= opcode[5:4]; reg_w <= 1; end
                end
                3: begin t <= 0; reg_n <= `REG_SP; reg_w <= 1; {reg_u, reg_l} <= cursor; end

            endcase

            /* 1 JP (HL) */
            8'b11_101_001: case (t)

                0: begin pc <= hl; end

            endcase

            /* 1 LD SP, HL */
            8'b11_111_001: case (t)

                0: begin pc <= pc + 1; reg_n <= `REG_SP; reg_w <= 1; {reg_u, reg_l} <= hl; end

            endcase

            /* 4 JP c, ** | JP ** */
            8'b11_000_011,
            8'b11_xxx_010: case (t)

                0: begin t <= 1; pc <= pc + 1'b1; end
                1: begin t <= 2; pc <= pc + 1'b1; reg_l <= pin_i; end
                2: begin t <= 3; pc <= pc + 1'b1; reg_u <= pin_i; end
                3: begin t <= 0; if (ccc) pc <= {reg_u, reg_l}; end

            endcase

            /* 2 OUT (*), A */
            8'b11_010_011: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 0; pc <= pc + 1; pin_pa <= pin_i; pin_po <= a; pin_pw <= 1; end

            endcase

            /* 3 IN  A, (*) */
            8'b11_011_011: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; pin_pa <= pin_i; end
                2: begin t <= 0; reg_l <= pin_pi; reg_b <= 1; reg_n <= `REG_A; end

            endcase

            /* 5 EX (SP), HL */
            8'b11_100_011: case (t)

                0: begin t <= 1; alt_a <= 1; cursor <= sp; pc <= pc + 1;  end
                1: begin t <= 2; alt_a <= 1; reg_l <= pin_i; pin_o <= hl[7:0]; pin_enw <= 1; end
                2: begin t <= 3; alt_a <= 1; cursor <= cursor + 1; end
                3: begin t <= 4; alt_a <= 1; reg_u <= pin_i; reg_w <= 1; reg_n <= `REG_HL; pin_o <= hl[15:8]; pin_enw <= 1; end
                4: begin t <= 0; end

            endcase

            /* 1 EX DE, HL */
            8'b11_101_011: case (t)

                0: begin pc <= pc + 1; ex_de_hl <= 1; end

            endcase

            /* 1 DI, EI */
            8'b11_11x_011: case (t)

                0: begin pc <= pc + 1; ei_ <= opcode[3]; end

            endcase

            /* 3/6 CALL c, ** */
            8'b11_001_101,
            8'b11_xxx_100: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; reg_l <= pin_i; end
                2: begin         pc <= pc + 1; reg_u <= pin_i; cursor <= sp;
                         t <= ccc ? 3 : 0; end
                3: begin t <= 4; pin_o <= pc[15:8]; pin_enw <= 1; alt_a <= 1; cursor <= cursor - 1; end
                4: begin t <= 5; pin_o <= pc[ 7:0]; pin_enw <= 1; alt_a <= 1; cursor <= cursor - 1; end
                5: begin t <= 0; reg_w <= 1; reg_n <= `REG_SP; pc <= {reg_u, reg_l}; {reg_u, reg_l} <= cursor; end

            endcase

            /* 4 PUSH r16 */
            8'b11_xx0_101: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; cursor <= sp; end
                1: begin t <= 2; alt_a <= 1; pin_o <= (reg_n == 2'b11) ? a : reg_r16[15:8]; pin_enw <= 1; cursor <= cursor - 1; end
                2: begin t <= 3; alt_a <= 1; pin_o <= (reg_n == 2'b11) ? f : reg_r16[ 7:0]; pin_enw <= 1; cursor <= cursor - 1; end
                3: begin t <= 0; reg_w <= 1; reg_n <= `REG_SP; {reg_u, reg_l} <= cursor; end

            endcase

            /* 3 <alu> A, i8 */
            8'b11_xxx_110: case (t)

                0: begin t <= 1; pc <= pc + 1; alu_m <= opcode[5:3]; op1 <= a; end
                1: begin t <= 2; pc <= pc + 1; op2 <= pin_i; end
                2: begin t <= 0; reg_l <= alu_r; f <= alu_f; reg_n <= `REG_A; reg_b <= (alu_m != 3'b111); end

            endcase

            /* 4 RST # */
            8'b11_xxx_111: case (t)

                0: begin t <= 1; pc    <= pc + (!pend_int); cursor <= sp; end
                1: begin t <= 2; pin_o <= pc[15:8]; pin_enw <= 1; cursor <= cursor - 1; alt_a <= 1; end
                2: begin t <= 3; pin_o <= pc[ 7:0]; pin_enw <= 1; cursor <= cursor - 1; alt_a <= 1; end
                3: begin t <= 0; reg_w <= 1; reg_n <= `REG_SP; {reg_u, reg_l} <= cursor; pc <= {opcode[5:3], 3'b000}; end

            endcase

        endcase

    end
end

// ---------------------------------------------------------------------
// Арифметико-логическое устройство
// ---------------------------------------------------------------------

wire flag_sign =   alu_r[7];    // Знак
wire flag_zero = ~|alu_r[7:0];  // Нуль
wire flag_prty = ~^alu_r[7:0];  // Четность

always @* begin

    case (alu_m)

        /* op1 + op2 => r */
        `ALU_ADD: begin

            alu_r = op1 + op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ op1[3:0] + op2[3:0] > 5'hF,
                /* 0 */ 1'b0,
                /* P */ (op1[7] == op2[7]) && (op1[7] != alu_r[7]),
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 + op2 + carry => r */
        `ALU_ADC: begin

            alu_r = op1 + op2 + f[ `CARRY ];
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ op1[3:0] + op2[3:0] + f[`CARRY] > 5'hF,
                /* 0 */ 1'b0,
                /* P */ (op1[7] == op2[7]) && (op1[7] != alu_r[7]),
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 - op2 => r */
        `ALU_SUB: begin

            alu_r = op1 - op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ op1[3:0] < op2[3:0],
                /* 0 */ 1'b0,
                /* P */ (op1[7] != op2[7]) && (op1[7] != alu_r[7]),
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 - op2 - carry => r */
        `ALU_SBC: begin

            alu_r = op1 - op2 - f[`CARRY];
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ op1[3:0] < op2[3:0] + f[`CARRY],
                /* 0 */ 1'b0,
                /* P */ (op1[7] != op2[7]) && (op1[7] != alu_r[7]),
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 & op2 => r */
        `ALU_AND: begin

            alu_r = op1 & op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 ^ op2 => r */
        `ALU_XOR: begin

            alu_r = op1 ^ op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 | op2 */
        `ALU_OR: begin

            alu_r = op1 | op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* op1 - op2 */
        `ALU_CP: begin

            alu_r = op1 - op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ op1[3:0] < op2[3:0],
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        `ALU_RLC: begin

            alu_r = {op1[6:0], op1[7]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ op1[7]

            };

        end

        `ALU_RRC: begin

            alu_r = {op1[0], op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ op1[0]

            };

        end

        `ALU_RL: begin

            alu_r = {op1[6:0], f[`CARRY]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ op1[7]

            };

        end

        `ALU_RR: begin

            alu_r = {f[`CARRY], op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ 1'b0,
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ op1[0]

            };

        end

        `ALU_DAA: begin

            alu_r = a
                    + ((f[`AUX]   | (a[3:0] >  4'h9)) ? 8'h06 : 0)
                    + ((f[`CARRY] | (a[7:0] > 8'h99)) ? 8'h60 : 0);

            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ 1'b0,
                /* A */ a[4] ^ alu_r[4],
                /* 0 */ 1'b0,
                /* P */ flag_prty,
                /* 1 */ 1'b1,
                /* C */ f[`CARRY] | (a > 8'h99)

            };

        end

        `ALU_CPL: begin

            alu_r = ~a;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ 1'b0,
                /* A */ 1'b1,
                /* 0 */ 1'b0,
                /* P */ f[`PARITY],
                /* 1 */ 1'b1,
                /* C */ f[`CARRY]

            };

        end

        `ALU_SCF: begin

            alu_r = a;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ 1'b0,
                /* A */ f[`AUX],
                /* 0 */ 1'b0,
                /* P */ f[`PARITY],
                /* 1 */ 1'b1,
                /* C */ 1'b1

            };

        end

        `ALU_CCF: begin

            alu_r = a;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ 1'b0,
                /* A */ f[`AUX],
                /* 0 */ 1'b0,
                /* P */ f[`PARITY],
                /* 1 */ 1'b1,
                /* C */ f[`CARRY] ^ 1'b1

            };

        end

    endcase

end

// ---------------------------------------------------------------------
// Работа с регистрами
// ---------------------------------------------------------------------

// Чтение
always @* begin

    reg_r8  = 8'h00;
    reg_r16 = 16'h0000;

    case (reg_n)

        3'h0: reg_r8 = bc[15:8];
        3'h1: reg_r8 = bc[ 7:0];
        3'h2: reg_r8 = de[15:8];
        3'h3: reg_r8 = de[ 7:0];
        3'h4: reg_r8 = hl[15:8];
        3'h5: reg_r8 = hl[ 7:0];
        3'h6: reg_r8 = f;
        3'h7: reg_r8 = a;

    endcase

    case (reg_n)

        3'h0:   reg_r16 = bc;
        3'h1:   reg_r16 = de;
        3'h2:   reg_r16 = hl;
        3'h3:   reg_r16 = sp;
        3'h4:   reg_r16 = {a, f};

    endcase

end

// Запись в регистры
always @(negedge pin_clk) begin

    if (ex_de_hl) begin

        de <= hl;
        hl <= de;

    end
    else
    if (reg_w) begin

        case (reg_n)

            3'h0: bc <= {reg_u, reg_l};
            3'h1: de <= {reg_u, reg_l};
            3'h2: hl <= {reg_u, reg_l};
            3'h3: sp <= {reg_u, reg_l};

        endcase

    end
    else
    if (reg_b) begin

        case (reg_n)

            3'h0: bc[15:8] <= reg_l;
            3'h1: bc[ 7:0] <= reg_l;
            3'h2: de[15:8] <= reg_l;
            3'h3: de[ 7:0] <= reg_l;
            3'h4: hl[15:8] <= reg_l;
            3'h5: hl[ 7:0] <= reg_l;
            /* (hl) */
            3'h7: a <= reg_l;

        endcase

    end

end

endmodule
