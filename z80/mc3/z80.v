module z80(

    /* Шина данных */
    input   wire         pin_clk,
    input   wire [ 7:0]  pin_i,
    output  wire [15:0]  pin_a,         // Указатель на адрес
    output  reg          pin_enw,       // Разрешить запись ы(высокий уровень)
    output  reg  [ 7:0]  pin_o,

    /* Порты */
    output  reg  [15:0]  pin_pa,
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
`define ALU_SLA     5'h10
`define ALU_SRA     5'h11
`define ALU_SLL     5'h12
`define ALU_SRL     5'h13
`define ALU_BIT     5'h15
`define ALU_RES     5'h16
`define ALU_SET     5'h17

`define CARRY       0
`define NEG         1
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

`define CMD_NOPE    3'b000
`define CMD_EXDEHL  3'b001
`define CMD_EXAF    3'b010
`define CMD_EXX     3'b011
`define CMD_INC     3'b100 // LDI, CPI...
`define CMD_DEC     3'b101 // LDD, CPD...

initial begin

    pin_enw = 0;
    pin_o   = 0;
    pin_pa  = 0;
    pin_po  = 0;

end

/* Указатель на необходимые данные */
assign pin_a = alt_a ? cursor : pc;

/* Управляющие регистры */
reg  [ 2:0] t       = 0;        // Это t-state
reg  [ 2:0] m       = 0;        // Это m-state
reg         halt    = 0;        // Процессор остановлен

reg         ei      = 0;        // Enabled Interrupt
reg         di      = 0;        // Disabled Interrupt
reg         iff1    = 0;
reg         iff2    = 0;
reg         iff1_   = 0;
reg         iff2_   = 0;

reg  [15:0] cursor  = 0;
reg         alt_a   = 1'b0;     // =0 pc  =1 cursor

/* Регенерация */
wire [ 6:0] RL = r[6:0] + 1;
wire [ 7:0] RI = {r[7], RL};

/* Регистры общего назначения */
reg  [ 7:0] a  =  8'hEF;
reg  [ 7:0] f  =  8'h00;
reg  [15:0] bc = 16'h0376;
reg  [15:0] de = 16'h0100;
reg  [15:0] HL = 16'h0000;

/* Регистр, зависимый от префикса */
wire [15:0] hl  = (pe | pex) ? (pem ? iy : ix) : HL;

/* +disp8 для префикса */
wire [15:0] xof = cursor + {{8{pin_i[7]}}, pin_i[7:0]};
wire        x20 = ((pe | pex) & opcode[2:0] == 3'b110);
wire        x53 = ((pe | pex) & opcode[5:3] == 3'b110);

/* Дополнительные регистры */
reg  [15:0] bc_ = 16'h0000;
reg  [15:0] de_ = 16'h0000;
reg  [15:0] hl_ = 16'h0000;
reg  [ 7:0] a_  =  8'h00;
reg  [ 7:0] f_  =  8'h81;

/* Управляющие */
reg  [15:0] pc = 16'h0000;
reg  [15:0] sp = 16'h0000;
reg  [15:0] ix = 16'h0102;
reg  [15:0] iy = 16'h0000;
reg  [ 7:0] i  = 8'h00;         // Вектор пользовательского прерывания
reg  [ 1:0] im = 2'b01;         // Interrupt Mode (IM)
reg  [ 7:0] r  = 8'h00;         // Регистр регенерации

/* Сохраненный опкод */
wire [ 7:0] opcode          = t ? opcode_latch : (interrupt ? 8'hFF : pin_i);
reg  [ 7:0] opcode_latch    = 8'h00; // Защелка для опкода
reg  [ 7:0] opcode_ext      = 8'h00; // Расширенный опкод
reg         prev_intr       = 1'b0;
reg         pend_int        = 1'b0;
wire        interrupt       = pend_int & !pe;
wire [15:0] pc8rel          = pc + 1 + {{8{pin_i[7]}}, pin_i[7:0]};

/* Префиксы IX, IY */
reg         pe      = 1'b0;     // Объявление префикса
reg         pex     = 1'b0;     // Фиксация префикса на инструкцию
reg         pem     = 1'b0;     // 0=IX, 1=IY

/* Управление записью в регистры */
reg         reg_b   = 1'b0;     // Сигнал на запись 8 битного регистра
reg         reg_w   = 1'b0;     // Сигнал на запись 16 битного регистра (reg_u:reg_v)
reg  [ 2:0] reg_n   = 3'h0;     // Номер регистра
reg  [ 7:0] reg_l   = 8'h00;    // Что писать
reg  [ 7:0] reg_u   = 8'h00;    // Что писать
reg  [ 7:0] reg_r8;             // reg_r8  = regs8 [ reg_n ]
reg  [15:0] reg_r16;            // reg_r16 = regs16[ reg_n ]
reg   [2:0] cmd;                // Особая инструкция для регистров

/* Определение условий */
wire        reg_hl  = (reg_n == 3'b110);

/* JR */
wire        cc      = (opcode[4] == 1'b0 && (f[`ZERO]   == opcode[3])) |
                      (opcode[4] == 1'b1 && (f[`CARRY]  == opcode[3])) |
                       opcode == 8'b00_011_000;

/* JP, CALL, RET */
wire        ccc     = (opcode[5:4] == 2'b00) & (f[`ZERO]   == opcode[3]) | // NZ, Z,
                      (opcode[5:4] == 2'b01) & (f[`CARRY]  == opcode[3]) | // NC, C,
                      (opcode[5:4] == 2'b10) & (f[`PARITY] == opcode[3]) | // PO, PE
                      (opcode[5:4] == 2'b11) & (f[`SIGN]   == opcode[3]) | // P, M
                       opcode == 8'b11_001_001 | // RET
                       opcode == 8'b11_000_011 | // JP
                       opcode == 8'b11_001_101;  // CALL

/* Арифметическое-логическое устройство */
reg  [ 4:0] alu_m = 0;
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

        pend_int <= iff1;
        pc <= pc + (iff1 & halt);

    end

    /* Исполнение опкодов */
    else begin

        /* Запись опкода в защелку в начале выполнения инструкции.
           Обработка прерывания.
           Префиксированные не выполнять! */

        if (t == 0) begin

            /* Записать код инструкции */
            opcode_latch <= pin_i;

            /* Отложенная запись в регистр IFF при сигнале DI / EI */
            if (pe == 0) begin

                iff1         <= iff1_;
                iff2         <= iff2_;
                iff1_        <= ei ? 1'b1 : (di ? 1'b0 : iff1_);
                iff2_        <= ei ? 1'b1 : (di ? 1'b0 : iff2_);

                /* RST $38 */
                opcode_latch <= pend_int ? 8'hFF : pin_i;
                pend_int     <= 1'b0;

            end

        end

        /* Сохранить НАЛИЧИЕ префикса, если он был объявлен ранее
           Остается до момента окончания инструкции и обнуляется при t=0
           (если не было DD/FD) */

        pex      <= t ? pex : pe;

        /* Подготовка управляющих сигналов */
        alt_a    <= 1'b0;
        reg_b    <= 1'b0;
        reg_w    <= 1'b0;
        pin_enw  <= 1'b0;
        pin_pw   <= 1'b0;
        halt     <= 1'b0;
        cmd      <= 3'b000;
        pe       <= 1'b0;
        ei       <= 1'b0;
        di       <= 1'b0;

        casex (opcode)

            /* LD r, i16 */
            8'b00_xx0_001: case (t)

                0: begin pc <= pc + 1; t <= 1; reg_n <= opcode[5:4]; end
                1: begin pc <= pc + 1; t <= 2; reg_l <= pin_i; end
                2: begin pc <= pc + 1; t <= 0; reg_u <= pin_i; reg_w <= 1'b1; end

            endcase

            /* EX AF, AF' */
            8'b00_001_000: case (t)

                0: begin pc <= pc + 1; cmd <= `CMD_EXAF; f <= f_; f_ <= f; end

            endcase

            /* DJNZ * */
            8'b00_010_000: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_b <= 1; reg_n <= `REG_B; reg_l <= bc[15:8] - 1; end
                1: begin t <= 0; pc <= bc[15:8] ? pc8rel : (pc + 1); end

            endcase

            /* JR cc, * | JR * */
            8'b00_011_000,
            8'b00_1xx_000: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 0; pc <= cc ? pc8rel : (pc + 1); end

            endcase

            /* ADD HL, r16 */
            8'b00_xx1_001: case (t)

                // Записать L -> op1, выбрать регистр (reg_n) C,E,L,A
                0: begin t <= 1; op1 <= hl[7:0]; reg_n <= {opcode[5:4], 1'b1}; pc <= pc + 1; end
                1: begin t <= 2; op2 <= reg_r8;  reg_n <= {opcode[5:4], 1'b0}; alu_m <= `ALU_ADD; end
                2: begin t <= 3;
                
                         op1    <= hl[15:8];
                         op2    <= reg_r8;   
                         reg_n  <= `REG_L;
                         reg_b  <= 1'b1;
                         reg_l  <= alu_r[7:0];

                         f[`CARRY] <= alu_f[`CARRY];
                         alu_m     <= `ALU_ADC;
                end
                3: begin t <= 0;

                        reg_n <= `REG_H;
                        reg_l <= alu_r[7:0];
                        reg_b <= 1'b1;

                        f[`NEG]   <= 1'b0;
                        f[`AUX]   <= alu_f[`AUX];
                        f[`CARRY] <= alu_f[`CARRY];
                        f[3]      <= alu_f[3];
                        f[5]      <= alu_f[5];
                 end

            endcase

            /* LD (r16), A */
            8'b00_0x0_010: case (t)

                0: begin t <= 1; pc <= pc + 1; cursor <= opcode[4] ? de : bc; alt_a <= 1; pin_o <= a; pin_enw <= 1; end
                1: begin t <= 0; alt_a <= 0; end

            endcase

            /* LD A, (r16) */
            8'b00_0x1_010: case (t)

                0: begin t <= 1; pc <= pc + 1; cursor <= opcode[4] ? de : bc; alt_a <= 1; end
                1: begin t <= 0; reg_b <= 1; reg_l <= pin_i; reg_n <= `REG_A; end

            endcase

            /* LD (**), HL */
            8'b00_100_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[7:0] <= pin_i; end
                2: begin t <= 3; pin_enw <= 1; alt_a <= 1; pin_o <= hl[ 7:0]; cursor[15:8] <= pin_i; end
                3: begin t <= 4; pin_enw <= 1; alt_a <= 1; pin_o <= hl[15:8]; cursor <= cursor + 1;  end
                4: begin t <= 0; pc <= pc + 1; end

            endcase

            /* LD HL, (**) */
            8'b00_101_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[ 7:0] <= pin_i; end
                2: begin t <= 3; pc <= pc + 1; cursor[15:8] <= pin_i; alt_a <= 1; end
                3: begin t <= 4; reg_b <= 1; reg_n <= `REG_L; reg_l <= pin_i; alt_a <= 1; cursor <= cursor + 1; end
                4: begin t <= 0; reg_b <= 1; reg_n <= `REG_H; reg_l <= pin_i;  end

            endcase

            /* LD (**), A */
            8'b00_110_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[7:0] <= pin_i; end
                2: begin t <= 3; pin_enw <= 1; alt_a <= 1; pin_o <= a[7:0]; cursor[15:8] <= pin_i; end
                3: begin t <= 0; pc <= pc + 1; end

            endcase

            /* LD A, (**) */
            8'b00_111_010: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; cursor[ 7:0] <= pin_i; end
                2: begin t <= 3; pc <= pc + 1; cursor[15:8] <= pin_i; alt_a <= 1; end
                3: begin t <= 0; reg_b <= 1; reg_n <= `REG_A; reg_l <= pin_i; end

            endcase

            /* INC r16 */
            8'b00_xx0_011: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; end
                1: begin t <= 0; {reg_u, reg_l} <= reg_r16 + 1; reg_w <= 1; end

            endcase

            /* DEC r16 */
            8'b00_xx1_011: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; end
                1: begin t <= 0; {reg_u, reg_l} <= reg_r16 - 1; reg_w <= 1; end

            endcase

            /* INC r8 */
            /* DEC r8 */
            8'b00_xxx_10x: case (t)

                0: begin t <= x53 ? 1 : 2; pc <= pc + 1; reg_n <= opcode[5:3]; cursor <= hl; alt_a <= !x53; end
                1: begin t <= 2; pc <= pc + 1; cursor <= xof; alt_a <= 1; end
                2: begin t <= 3; op1 <= reg_hl ? pin_i : reg_r8; op2 <= 1; alu_m <= opcode[0] ? `ALU_SUB : `ALU_ADD; end
                3: begin t <= 4; pin_enw <= reg_hl; reg_b <= ~reg_hl; reg_l <= alu_r; pin_o <= alu_r; f <= alu_f; alt_a <= 1; end
                4: begin t <= 0; end

            endcase

            /* LD r, i8 */
            8'b00_xxx_110: case (t)

                0: begin t <= x53 ? 1 : 2; pc <= pc + 1; reg_n <= opcode[5:3]; cursor <= hl; end
                1: begin t <= 2; pc <= pc + 1; cursor <= xof; end
                2: begin t <= 3; pc <= pc + 1; reg_b <= ~reg_hl; pin_enw <= reg_hl; reg_l <= pin_i; pin_o <= pin_i; alt_a <= 1; end
                3: begin t <= 0; end

            endcase

            /* RLCA, RRCA, RLA, RRA,
               DAA, CPL, SCF, CCF */
            8'b00_xxx_111: case (t)

                0: begin t <= 1; pc <= pc + 1; alu_m <= {1'b1, opcode[5:3]}; op1 <= a; end
                1: begin t <= 0; reg_b <= 1; reg_l <= alu_r; reg_n <= `REG_A; f <= alu_f; end

            endcase

            /* LD r, r */
            8'b01_110_110: halt <= 1;
            8'b01_xxx_xxx: case (t)

                0: begin t <= x20 ? 1 : 2; pc <= pc + 1; reg_n <= opcode[2:0]; alt_a <= !x20; cursor <= hl; end
                1: begin t <= 2; pc <= pc + 1; cursor <= xof; alt_a <= 1; end
                2: begin t <= x53 ? 3 : 4; reg_l <= reg_hl ? pin_i : reg_r8; reg_n <= opcode[5:3]; end
                3: begin t <= 4; pc <= pc + 1; cursor <= xof; end
                4: begin t <= 5; reg_b <= ~reg_hl; pin_enw <= reg_hl; pin_o <= reg_l; alt_a <= 1; end
                5: begin t <= 0; end

            endcase

            /* <alu> A, r */
            8'b10_xxx_xxx: case (t)

                0: begin t <= x20 ? 1 : 2; op1 <= a; pc <= pc + 1; reg_n <= opcode[2:0]; cursor <= hl; alt_a <= !x20; end
                1: begin t <= 2; pc <= pc + 1; cursor <= xof; alt_a <= 1; end
                2: begin t <= 3; op2 <= reg_hl ? pin_i : reg_r8; alu_m <= opcode[5:3]; end
                3: begin t <= 0; reg_b <= (alu_m != 3'b111); reg_n <= `REG_A; reg_l <= alu_r; f <= alu_f; end

            endcase

            /* RET c | RET */
            8'b11_001_001,
            8'b11_xxx_000: case (t)

                0: begin t <= ccc; alt_a <= ccc; pc <= pc + 1; cursor <= sp; end
                1: begin t <= 2; pc[ 7:0] <= pin_i; alt_a <= 1; cursor <= cursor + 1; end
                2: begin t <= 0; pc[15:8] <= pin_i; {reg_u, reg_l} <= cursor + 1; reg_n <= `REG_SP; reg_w <= 1; end

            endcase

            /* EXX */
            8'b11_011_001: case (t)

                0: begin pc <= pc + 1; cmd <= `CMD_EXX; end

            endcase

            /* POP r16 */
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

            /* JP (HL) */
            8'b11_101_001: case (t)

                0: begin pc <= hl; end

            endcase

            /* LD SP, HL */
            8'b11_111_001: case (t)

                0: begin pc <= pc + 1; reg_n <= `REG_SP; reg_w <= 1; {reg_u, reg_l} <= hl; end

            endcase

            /* JP c, ** | JP ** */
            8'b11_000_011,
            8'b11_xxx_010: case (t)

                0: begin t <= 1; pc <= pc + 1'b1; end
                1: begin t <= 2; pc <= pc + 1'b1; reg_l <= pin_i; end
                2: begin t <= 3; pc <= pc + 1'b1; reg_u <= pin_i; end
                3: begin t <= 0; if (ccc) pc <= {reg_u, reg_l}; end

            endcase

            /* OUT (*), A */
            8'b11_010_011: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 0; pc <= pc + 1; pin_pa <= pin_i; pin_po <= a; pin_pw <= 1; end

            endcase

            /* IN  A, (*)*/
            8'b11_011_011: case (t)

                0: begin t <= 1; pc <= pc + 1; end
                1: begin t <= 2; pc <= pc + 1; pin_pa <= pin_i; end
                2: begin t <= 0; reg_l <= pin_pi; reg_b <= 1; reg_n <= `REG_A; end

            endcase

            /* EX (SP), HL */
            8'b11_100_011: case (t)

                0: begin t <= 1; alt_a <= 1; cursor <= sp; pc <= pc + 1;  end
                1: begin t <= 2; alt_a <= 1; reg_l <= pin_i; pin_o <= hl[7:0]; pin_enw <= 1; end
                2: begin t <= 3; alt_a <= 1; cursor <= cursor + 1; end
                3: begin t <= 4; alt_a <= 1; reg_u <= pin_i; reg_w <= 1; reg_n <= `REG_HL; pin_o <= hl[15:8]; pin_enw <= 1; end
                4: begin t <= 0; end

            endcase

            /* EX DE, HL */
            8'b11_101_011: case (t)

                0: begin pc <= pc + 1; cmd <= `CMD_EXDEHL; end

            endcase

            /* DI, EI */
            8'b11_11x_011: case (t)

                0: begin pc <= pc + 1; ei <= opcode[3]; di <= !opcode[3]; end

            endcase

            /* CALL c, ** */
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

            /* PUSH r16 */
            8'b11_xx0_101: case (t)

                0: begin t <= 1; pc <= pc + 1; reg_n <= opcode[5:4]; cursor <= sp; end
                1: begin t <= 2; alt_a <= 1; pin_o <= (reg_n == 2'b11) ? a : reg_r16[15:8]; pin_enw <= 1; cursor <= cursor - 1; end
                2: begin t <= 3; alt_a <= 1; pin_o <= (reg_n == 2'b11) ? f : reg_r16[ 7:0]; pin_enw <= 1; cursor <= cursor - 1; end
                3: begin t <= 0; reg_w <= 1; reg_n <= `REG_SP; {reg_u, reg_l} <= cursor; end

            endcase

            /* <alu> A, i8 */
            8'b11_xxx_110: case (t)

                0: begin t <= 1; pc <= pc + 1; alu_m <= opcode[5:3]; op1 <= a; end
                1: begin t <= 2; pc <= pc + 1; op2 <= pin_i; end
                2: begin t <= 0; reg_l <= alu_r; f <= alu_f; reg_n <= `REG_A; reg_b <= (alu_m != 3'b111); end

            endcase

            /* RST # */
            8'b11_xxx_111: case (t)

                /* TODO IM 2 */

                0: begin t <= 1; pc <= pc + (im == 2'b01 ? (!interrupt) : 1); cursor <= sp;
                         iff1  <= interrupt ? 0 : iff1;
                         iff1_ <= interrupt ? 0 : iff1_; end
                1: begin t <= 2; pin_o <= pc[15:8]; pin_enw <= 1; cursor <= cursor - 1; alt_a <= 1; end
                2: begin t <= 3; pin_o <= pc[ 7:0]; pin_enw <= 1; cursor <= cursor - 1; alt_a <= 1; end
                3: begin t <= 0; reg_w <= 1; reg_n <= `REG_SP; {reg_u, reg_l} <= cursor; pc <= {opcode[5:3], 3'b000}; end

            endcase

            /* IX / IY */
            8'b11_x11_101: case (t)

                0: begin pc <= pc + 1; pe <= 1; pem <= opcode[5]; end

            endcase

            /* CB */
            8'b11_001_011: case (t)

                0: begin t <= (pe | pex) ? 1 : 2; pc <= pc + 1; cursor <= hl; end
                1: begin t <= 2; pc <= pc + 1; cursor <= xof; end
                2: begin t <= 3;
                         pc    <=  pc + 1;
                         /* Если нет префикса, то обычный HL, иначе в любом случае IX/IY + disp8 */
                         alt_a <= (!pex & (pin_i[2:0] == 3'b110)) | pex;
                         reg_n <=  pin_i[2:0];
                         opcode_ext <= pin_i;
                end
                3: begin

                    t   <= 4;
                    op1 <= opcode_ext[2:0] == 3'b110 ? pin_i : reg_r8;

                    casex (opcode_ext)

                        // RLC, RRC, RL, RR
                        8'b00_0xx_xxx: begin alu_m <= {3'b010, opcode_ext[4:3]}; end

                        // SLA, SRA, SLL, SRL
                        8'b00_1xx_xxx: begin alu_m <= {3'b100, opcode_ext[4:3]}; end

                        // BIT, RES, SET
                        default:       begin alu_m <= {3'b101, opcode_ext[7:6]}; op2 <= {opcode_ext[6], opcode_ext[5:3]}; end

                    endcase

                end
                4: begin t <= 5;
                         reg_b   <= !(opcode_ext[2:0] == 3'b110) & !pex;
                         pin_enw <=  (opcode_ext[2:0] == 3'b110) | pex;
                         pin_o   <= alu_r;
                         reg_l   <= alu_r; f <= alu_f;
                end
                5: begin t <= 0; alt_a <= 0; end

            endcase

            /* ED Extended Instructions */
            8'b11_101_101: case (t)

                0: begin r <= RI; t <= 1; pc <= pc + 1; m <= 0; pex <= 0; end
                1: begin r <= RI; t <= 2; pc <= pc + 1; opcode_ext <= pin_i; end
                2: casex (opcode_ext)

                    /* IN r, (C) */
                    8'b01_xxx_000: case (m)

                        0: begin m <= 1; pin_pa <= bc; end
                        1: begin t <= 0; reg_b <= 1; reg_n <= opcode_ext[5:3]; reg_l <= pin_pi;

                            f <= {

                                /* S */ pin_pi[7],
                                /* Z */ ~|pin_pi[7:0],
                                /* 0 */ pin_pi[5],
                                /* H */ 1'b0,
                                /* 0 */ pin_pi[3],
                                /* V */ ~^pin_pi[7:0],
                                /* 0 */ 1'b0,
                                /* C */ f[`CARRY]

                            };

                        end

                    endcase

                    /* OUT (C), r */
                    8'b01_xxx_001: case (m)

                        0: begin m <= 1; pin_pa <= bc; reg_n <= opcode_ext[5:3]; end
                        1: begin t <= 0; pin_po <= (reg_n == 3'b110) ? 0 : reg_r8; pin_pw <= 1; end

                    endcase

                    /* SBC HL, r16 */
                    8'b01_xx0_010: begin end

                    /* ADC HL, r16 */
                    8'b01_xx1_010: begin end

                    /* LD (**), r16 */
                    8'b01_xx0_011: begin end

                    /* LD r16, (**) */
                    8'b01_xx1_011: begin end

                    /* NEG */
                    8'b01_xxx_100: begin end

                    /* RETN */
                    8'b01_xxx_101: begin end

                    /* IM x */
                    8'b01_xxx_110: begin im <= opcode_ext[3] ? (opcode_ext[4] ? 2 : a[0]) : opcode_ext[4]; t <= 0; end

                    /* LD I, A */
                    8'b01_000_111: begin t <= 0; i <= a; end

                    /* LD R, A */
                    8'b01_001_111: begin t <= 0; r <= a; end

                    /* LD A, I */
                    8'b01_010_111: begin t <= 0; reg_b <= 1; reg_n <= `REG_A; reg_l <= i; end

                    /* LD A, R */
                    8'b01_011_111: begin t <= 0; reg_b <= 1; reg_n <= `REG_A; reg_l <= r; end

                    /* RRD */
                    8'b01_100_111: begin end

                    /* RLD */
                    8'b01_100_111: begin end

                    /* LDxx */
                    8'b10_1xx_000: case (m)

                        0: begin m <= 1; cursor <= hl; alt_a <= 1; end
                        1: begin m <= 2; cursor <= de; alt_a <= 1; pin_o <= pin_i; pin_enw <= 1; op1 <= pin_i; end
                        2: begin m <= 3; cmd <= opcode_ext[3] ? `CMD_DEC : `CMD_INC; end
                        3: begin t <= 0;

                            // Если есть REPEAT, вернуться на 2 назад
                            if (opcode_ext[4] && bc)
                                pc <= pc - 2;

                            f <= {

                                /* S */ f[`SIGN],
                                /* Z */ f[`ZERO],
                                /* 0 */ ldi_xy[5],
                                /* H */ 1'b0,
                                /* 0 */ ldi_xy[3],
                                /* V */ |bc[15:0],
                                /* 1 */ 1'b0,
                                /* C */ f[`CARRY]

                            };

                        end

                    endcase

                    /* CPxx */
                    /* INxx */
                    /* OTxx */

                endcase

            endcase

        endcase

    end
end

/* АЛУ */

wire flag_sign =   alu_r[7];    // Знак
wire flag_zero = ~|alu_r[7:0];  // Нуль
wire flag_prty = ~^alu_r[7:0];  // Четность
wire [5:0] ldi_xy = a + op1;    // Особые флаги

always @* begin

    case (alu_m)

        /* op1 + op2 => r */
        `ALU_ADD: begin

            alu_r = op1 + op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ op1[3:0] + op2[3:0] > 5'hF,
                /* 0 */ alu_r[3],
                /* V */ (op1[7] ^ op2[7] ^ 1'b1) & (op1[7] ^ alu_r[7]),
                /* 0 */ 1'b0,
                /* C */ alu_r[8]

            };

        end

        /* op1 + op2 + carry => r */
        `ALU_ADC: begin

            alu_r = op1 + op2 + f[ `CARRY ];
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ op1[3:0] + op2[3:0] + f[`CARRY] > 5'hF,
                /* 0 */ alu_r[3],
                /* V */ (op1[7] ^ op2[7] ^ 1'b1) & (op1[7] ^ alu_r[7]),
                /* 0 */ 1'b0,
                /* C */ alu_r[8]

            };

        end

        /* op1 - op2 => r */
        `ALU_SUB: begin

            alu_r = op1 - op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ op1[3:0] < op2[3:0],
                /* 0 */ alu_r[3],
                /* V */ (op1[7] ^ op2[7]) & (op1[7] ^ alu_r[7]),
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
                /* 0 */ alu_r[5],
                /* H */ op1[3:0] < op2[3:0] + f[`CARRY],
                /* 0 */ alu_r[3],
                /* V */ (op1[7] ^ op2[7]) & (op1[7] ^ alu_r[7]),
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
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ 1'b0

            };

        end

        /* op1 ^ op2 => r */
        `ALU_XOR: begin

            alu_r = op1 ^ op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ 1'b0

            };

        end

        /* op1 | op2 */
        `ALU_OR: begin

            alu_r = op1 | op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 1 */ 1'b0,
                /* C */ 1'b0

            };

        end

        /* op1 - op2 */
        `ALU_CP: begin

            alu_r = op1 - op2;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* A */ op1[3:0] < op2[3:0],
                /* 0 */ alu_r[3],
                /* V */ (op1[7] ^ op2[7]) & (op1[7] ^ alu_r[7]),
                /* 1 */ 1'b1,
                /* C */ alu_r[8]

            };

        end

        /* Циклический влево */
        `ALU_RLC: begin

            alu_r = {op1[6:0], op1[7]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ op1[7]

            };

        end

        /* Циклический вправо */
        `ALU_RRC: begin

            alu_r = {op1[0], op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ op1[0]

            };

        end

        /* Влево с заемом из C */
        `ALU_RL: begin

            alu_r = {op1[6:0], f[`CARRY]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 1 */ 1'b0,
                /* C */ op1[7]

            };

        end

        /* Вправо с заемом из C */
        `ALU_RR: begin

            alu_r = {f[`CARRY], op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 1 */ 1'b0,
                /* C */ op1[0]

            };

        end

        /* Десятично-двоичная корректировка */
        `ALU_DAA: begin

            if (f[`NEG])
                alu_r = op1
                        - ((f[`AUX]   | (op1[3:0] >  4'h9)) ? 8'h06 : 0)
                        - ((f[`CARRY] | (op1[7:0] > 8'h99)) ? 8'h60 : 0);
            else
                alu_r = op1
                        + ((f[`AUX]   | (op1[3:0] >  4'h9)) ? 8'h06 : 0)
                        + ((f[`CARRY] | (op1[7:0] > 8'h99)) ? 8'h60 : 0);

            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* A */ op1[4] ^ alu_r[4],
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 1 */ f[`NEG],
                /* C */ f[`CARRY] | (op1 > 8'h99)

            };

        end

        /* a ^ $FF */
        `ALU_CPL: begin

            alu_r = ~op1;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ alu_r[5],
                /* A */ 1'b1,
                /* 0 */ alu_r[3],
                /* P */ f[`PARITY],
                /* 1 */ 1'b1,
                /* C */ f[`CARRY]

            };

        end

        /* CF=1 */
        `ALU_SCF: begin

            alu_r = op1;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ f[`PARITY],
                /* 0 */ 1'b0,
                /* C */ 1'b1

            };

        end

        /* CF^1 */
        `ALU_CCF: begin

            alu_r = op1;
            alu_f = {

                /* S */ f[`SIGN],
                /* Z */ f[`ZERO],
                /* 0 */ alu_r[5],
                /* H */ f[`CARRY],
                /* 0 */ alu_r[3],
                /* P */ f[`PARITY],
                /* 1 */ 1'b1,
                /* C */ f[`CARRY] ^ 1'b1

            };

        end

        /* Логический влево */
        `ALU_SLA,
        `ALU_SLL: begin

            alu_r = {op1[6:0], 1'b0};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* N */ 1'b0,
                /* C */ op1[7]

            };

        end

        /* Арифметический вправо */
        `ALU_SRA: begin

            alu_r = {op1[7], op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ op1[0]

            };

        end

        /* Логический вправо */
        `ALU_SRL: begin

            alu_r = {1'b0, op1[7:1]};
            alu_f = {

                /* S */ flag_sign,
                /* Z */ flag_zero,
                /* 0 */ alu_r[5],
                /* H */ 1'b0,
                /* 0 */ alu_r[3],
                /* P */ flag_prty,
                /* 0 */ 1'b0,
                /* C */ op1[0]

            };

        end

        /* Проверить бит */
        `ALU_BIT: begin

            alu_r = op1;
            alu_f = {

                /* S */ flag_sign,
                /* Z */ !op1[ op2[2:0] ], // Если бит = 0, ставим Z=1
                /* 0 */ alu_r[5],
                /* H */ 1'b1,
                /* 0 */ alu_r[3],
                /* P */ f[`ZERO],
                /* N */ 1'b0,
                /* C */ op1[0]

            };

        end

        /* Проверить бит */
        `ALU_RES,
        `ALU_SET: begin

            case (op2[2:0])

                3'b000: alu_r = {op1[7:1], op2[3]};
                3'b001: alu_r = {op1[7:2], op2[3], op1[  0]};
                3'b010: alu_r = {op1[7:3], op2[3], op1[1:0]};
                3'b011: alu_r = {op1[7:4], op2[3], op1[2:0]};
                3'b100: alu_r = {op1[7:5], op2[3], op1[3:0]};
                3'b101: alu_r = {op1[7:6], op2[3], op1[4:0]};
                3'b110: alu_r = {op1[  7], op2[3], op1[5:0]};
                3'b111: alu_r = {          op2[3], op1[6:0]};

            endcase

            alu_f = f;

        end

    endcase

end

/* Чтение из регистров */
always @* begin

    case (reg_n)

        3'h0: reg_r8 = bc[15:8];
        3'h1: reg_r8 = bc[ 7:0];
        3'h2: reg_r8 = de[15:8];
        3'h3: reg_r8 = de[ 7:0];
        3'h4: reg_r8 = (pe | pex) ? (pem ? iy[15:8] : ix[15:8]) : HL[15:8];
        3'h5: reg_r8 = (pe | pex) ? (pem ? iy[ 7:0] : ix[ 7:0]) : HL[ 7:0];
        3'h6: reg_r8 = f;
        3'h7: reg_r8 = a;

    endcase

    case (reg_n)

        3'h0: reg_r16 = bc;
        3'h1: reg_r16 = de;
        3'h2: reg_r16 = (pe | pex) ? (pem ? iy : ix) : HL;
        3'h3: reg_r16 = sp;
        3'h4: reg_r16 = {a, f};
        default: reg_r16 = 0;

    endcase

end

/* Запись в регистры */
always @(negedge pin_clk) begin

    if (cmd == `CMD_EXAF) begin

        a  <= a_;
        a_ <= a;

    end
    else
    if (cmd == `CMD_EXX) begin

        bc <= bc_; bc_ <= bc;
        de <= de_; de_ <= de;
        HL <= hl_; hl_ <= HL;

    end
    else
    if (cmd == `CMD_EXDEHL) begin

        de <= hl;

        if (pex)
        case (pem) 1'b0: ix <= de; 1'b1: iy <= de; endcase
        else HL <= de;

    end
    else
    if (cmd == `CMD_INC) begin

        bc <= bc - 1;
        de <= de + 1;
        HL <= HL + 1;

    end
    else
    if (cmd == `CMD_DEC) begin

        bc <= bc - 1;
        de <= de - 1;
        HL <= HL - 1;

    end
    else
    if (reg_w) begin

        case (reg_n)

            3'h0: bc <= {reg_u, reg_l};
            3'h1: de <= {reg_u, reg_l};
            3'h2: begin

                if (pex)
                case (pem) 1'b0: ix <= {reg_u, reg_l}; 1'b1: iy <= {reg_u, reg_l}; endcase
                else HL <= {reg_u, reg_l};

            end
            3'h3: sp <= {reg_u, reg_l};

        endcase

    end
    else
    if (reg_b) begin

        case (reg_n)

            /* B */ 3'h0: bc[15:8] <= reg_l;
            /* C */ 3'h1: bc[ 7:0] <= reg_l;
            /* D */ 3'h2: de[15:8] <= reg_l;
            /* E */ 3'h3: de[ 7:0] <= reg_l;
            /* H */ 3'h4: begin

                if (pex)
                case (pem) 1'b0: ix[15:8] <= reg_l; 1'b1: iy[15:8] <= reg_l; endcase
                else HL[15:8] <= reg_l;

            end
            /* L */ 3'h5: begin

                if (pex)
                case (pem) 1'b0: ix[ 7:0] <= reg_l; 1'b1: iy[ 7:0] <= reg_l; endcase
                else HL[7:0] <= reg_l;

            end
            /* (hl) */
            /* A */ 3'h7: a <= reg_l;

        endcase

    end

end

endmodule
