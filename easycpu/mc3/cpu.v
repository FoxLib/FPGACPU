// ПРЕРЫВАНИЯ ----------------------------------------------------------
// 0 RESET      BRA start
// 2 KEYB       BRA keyb_irq
// 4 MOUSE      BRA mouse_irq
// 6 TIMER      BRA timer_irq
// ---------------------------------------------------------------------
module cpu
(
    // Общие интерфейсы
    input  wire         CLOCK,      // Типичная частота 25 Мгц
    input  wire [ 7:0]  I_DATA,     // =memory[O_ADDR]
    output wire [15:0]  O_ADDR,     // Запрос в память
    output reg  [ 7:0]  O_DATA,     // Данные на запись
    output reg          O_WREN,     // Разрешение записи
    // Триггеры прерываний
    input  wire         IRQ_KEYB,   // При изменении значения
    input  wire         IRQ_MOUSE,  // ... запрос на
    input  wire         IRQ_TIMER   // ... вызов прерывания
);

// ---------------------------------------------------------------------
assign      O_ADDR  = alt ? address : ip; // Указатель в память | текущий ip
// ---------------------------------------------------------------------
initial     O_WREN  = 1'b0;
initial     O_DATA  = 8'h00;
initial     r[15]   = 16'hE000;     // Вершина стека по умолчанию
// ---------------------------------------------------------------------
reg         alt     = 0;            // 0-IP, 1-Address
reg [15:0]  address = 16'h0000;     // Указатель адреса
reg [ 7:0]  mopcode = 8'h00;        // Сохраненный опкод
reg [ 2:0]  tstate  = 3'h0;         // Состояние исполнения инструкции
reg [15:0]  tmp     = 16'h0000;     // Временный регистр
// ---------------------------------------------------------------------
reg [15:0]  ip      = 16'h0000;     // Счетчик инструкции
reg [15:0]  acc     = 16'h0002;     // Аккумулятор
reg         cf      = 1'b0;         // Carry Flag
reg         zf      = 1'b0;         // Zero Flag
reg         intf    = 1'b1;         // Interrupt Flag
reg [15:0]  r[16];                  // 16 регистров процессора 256 bit
// ---------------------------------------------------------------------
wire [7:0]  opcode  = tstate? mopcode : I_DATA; // Текущий опкод
wire [15:0] regin   = r[ opcode[3:0] ];
wire [ 1:0] cond    = {cf, zf};
wire [16:0] alu_add = acc + regin;
wire [16:0] alu_sub = acc - regin;
wire [15:0] alu_and = acc & regin;
wire [15:0] alu_xor = acc ^ regin;
wire [15:0] alu_ora = acc | regin;
// ---------------------------------------------------------------------
reg       irq_keyb  = 0;
reg       irq_mouse = 0;
reg       irq_timer = 0;
reg [1:0] irq_call  = 0;
// ---------------------------------------------------------------------

always @(posedge CLOCK) begin

    tstate <= tstate + 1;

    // Вызов прерывания
    if (irq_call) begin

        case (tstate)

            1: begin address <= r[15] - 2;   O_DATA <= ip[ 7:0]; O_WREN <= 1; alt <= 1; end
            2: begin address <= address + 1; O_DATA <= ip[15:8]; r[15]  <= r[15] - 2; end
            3: begin tstate  <= 0; intf <= 1'b0; O_WREN <= 0; ip <= {irq_call, 1'b0}; irq_call <= 0; alt <= 0; end

        endcase

    end
    // Обработка прерывания от клавиатуры
    else if (intf && tstate == 0 && IRQ_KEYB  != irq_keyb) begin

        irq_keyb    <= IRQ_KEYB;
        irq_call    <= 1;

    end
    // Обработка прерывания от мыши
    else if (intf && tstate == 0 && IRQ_MOUSE != irq_mouse) begin

        irq_mouse   <= IRQ_MOUSE;
        irq_call    <= 2;

    end
    // Обработка прерывания от таймера
    else if (intf && tstate == 0 && IRQ_TIMER != irq_timer) begin

        irq_timer   <= IRQ_TIMER;
        irq_call    <= 3;

    end

    // Исполнение инструкции
    else casex (opcode)

        // 0x LDI Rn, **
        8'b0000_xxxx: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; tmp[7:0] <= I_DATA; end
            2: begin ip <= ip + 1; r[ opcode[3:0] ] <= {I_DATA, tmp[7:0]}; tstate <= 0; end

        endcase

        // 10 LDA Word [**]
        8'b0001_0000: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; address[ 7:0] <= I_DATA; end
            2: begin ip <= ip + 1; address[15:8] <= I_DATA; alt <= 1; end
            3: begin acc[ 7:0] <= I_DATA; address <= address + 1; end
            4: begin acc[15:8] <= I_DATA; alt <= 0; tstate <= 0;  end

        endcase

        // 11 STA Word [**]
        8'b0001_0001: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; address[ 7:0] <= I_DATA; end
            2: begin O_DATA <= acc[7:0];  address[15:8] <= I_DATA; ip <= ip + 1; alt <= 1; O_WREN <= 1'b1; end
            3: begin O_DATA <= acc[15:8]; address <= address + 1; end
            4: begin O_WREN <= 1'b0; alt <= 0; tstate <= 0; end

        endcase

        // 12 SHR
        8'b0001_0010: begin acc <= {1'b0, acc[7:1]}; cf <= acc[0]; zf = ~|acc[7:1]; ip <= ip + 1; tstate <= 0; end

        // 13 LDA **
        8'b0001_0011: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; acc[ 7:0] <= I_DATA; end
            2: begin ip <= ip + 1; acc[15:8] <= I_DATA; tstate <= 0; end

        endcase

        // 14 SWAP
        8'b0001_0100: begin acc <= {acc[7:0], acc[15:8]}; ip <= ip + 1; tstate <= 0; end

        // 15 CALL **
        8'b0001_0101: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; tmp[ 7:0] <= I_DATA; end
            2: begin ip <= ip + 1; tmp[15:8] <= I_DATA; r[15] <= r[15] - 2;  end
            3: begin O_DATA <= ip[ 7:0]; address <= r[15]; alt <= 1; O_WREN <= 1; end
            4: begin O_DATA <= ip[15:8]; address <= address + 1; end
            5: begin tstate <= 0; O_WREN <= 0; ip <= tmp; alt <= 0;  end

        endcase

        // 16 RET  Возврат
        // 18 RETI Возврат и установка I=1
        8'b0001_0110,
        8'b0001_1000:
        case (tstate)

            0: begin address <= r[15]; r[15] <= r[15] + 2; alt <= 1; end
            1: begin ip[ 7:0] <= I_DATA; address <= address + 1; end
            2: begin ip[15:8] <= I_DATA; tstate <= 0; alt <= 0; if (opcode[3]) intf <= 1'b1; end

        endcase

        // 17 NOP
        8'b0001_0111: begin ip <= ip + 1; tstate <= 0; end

        // 19|1A CLI, STI
        8'b0001_1001,
        8'b0001_1010: begin ip <= ip + 1; tstate <= 0; intf <= opcode[1]; end

        // 1B CLH Очистка 15:8
        8'b0001_1011: begin ip <= ip + 1; tstate <= 0; acc[15:8] <= 0; end

        // 2x LDA Word [Rn] Загрузка 16-битных данных по адресу Rn
        8'b0010_xxxx: case (tstate)

            0: begin ip <= ip + 1; address <= regin; alt <= 1'b1; end
            1: begin acc[ 7:0] <= I_DATA; address <= address + 1'b1; end
            2: begin acc[15:8] <= I_DATA; alt <= 0; tstate <= 0; end

        endcase

        // 3x STA Byte [Rn] Выгрузка младших 8 бит по адресу Rn
        8'b0011_xxxx: case (tstate)

            0: begin address <= regin; alt <= 1'b1; O_WREN <= 1; O_DATA <= acc[7:0]; ip <= ip + 1; end
            1: begin tstate <= 0; alt <= 0; O_WREN <= 0; end

        endcase

        // 4x LDA Rn
        // 5x STA Rn
        8'b0100_xxxx: begin acc <= regin; ip <= ip + 1; tstate <= 0; end
        8'b0101_xxxx: begin r[opcode[3:0]] <= acc; ip <= ip + 1; tstate <= 0; end

        // 6x ADD Rn | 7x SUB Rn | 9x AND Rn | Ax XOR Rn | Bx ORA Rn
        8'b0110_xxxx: begin acc <= alu_add[15:0]; cf <= alu_add[16]; zf = ~|alu_add[15:0]; ip <= ip + 1; tstate <= 0; end
        8'b0111_xxxx: begin acc <= alu_sub[15:0]; cf <= alu_sub[16]; zf = ~|alu_sub[15:0]; ip <= ip + 1; tstate <= 0; end
        8'b1001_xxxx: begin acc <= alu_and[15:0]; zf = ~|alu_and[15:0]; ip <= ip + 1; tstate <= 0; end
        8'b1010_xxxx: begin acc <= alu_xor[15:0]; zf = ~|alu_xor[15:0]; ip <= ip + 1; tstate <= 0; end
        8'b1011_xxxx: begin acc <= alu_ora[15:0]; zf = ~|alu_ora[15:0]; ip <= ip + 1; tstate <= 0; end

        // 80 BRA *
        8'b1000_0000: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1 + {{8{I_DATA[7]}}, I_DATA}; tstate <= 0; end

        endcase

        // 81 JMP **
        8'b1000_0001: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; address[7:0] <= I_DATA; end
            2: begin ip <= {I_DATA, address[7:0]}; tstate <= 0; end

        endcase

        // 82-85 JMP <cond>
        8'b1000_001x,
        8'b1000_010x:
        case (tstate)

            0: if (cond[ opcode[1] ] != opcode[0]) begin tstate <= 0; ip <= ip + 3; end else ip <= ip + 1;
            1: begin ip <= ip + 1; address[7:0] <= I_DATA; end
            2: begin ip <= {I_DATA, address[7:0]}; tstate <= 0; end

        endcase

        // 8A-8D BRA <cond>
        8'b1000_101x,
        8'b1000_110x:
        case (tstate)

            0: if (cond[ opcode[1] ] != opcode[0]) begin tstate <= 0; ip <= ip + 2; end else ip <= ip + 1;
            1: begin ip <= ip + 1 + {{8{I_DATA[7]}}, I_DATA}; tstate <= 0; end

        endcase

        // Cx INC Rn | Dx DEC Rn
        8'b1100_xxxx: begin r[opcode[3:0]] <= regin + 1; zf <= regin == 16'hFFFF; ip <= ip + 1; tstate <= 0; end
        8'b1101_xxxx: begin r[opcode[3:0]] <= regin - 1; zf <= regin == 16'h0001; ip <= ip + 1; tstate <= 0; end

        // Ex PUSH Rn
        8'b1110_xxxx: case (tstate)

            0: begin ip <= ip + 1; alt <= 1; address <= r[15] - 2; O_DATA <= regin[7:0]; O_WREN <= 1; r[15] <= r[15] - 2; end
            1: begin address <= address + 1; O_DATA <= regin[15:8]; end
            2: begin tstate <= 0; O_WREN <= 0; alt <= 0; end

        endcase

        // Fx POP Rn
        8'b1111_xxxx: case (tstate)

            0: begin ip <= ip + 1; address <= r[15]; r[15] <= r[15] + 2; alt <= 1; end
            1: begin tmp[7:0] <= I_DATA; address <= address + 1; end
            2: begin r[opcode[3:0]] <= {I_DATA, tmp[7:0]}; tstate <= 0; alt <= 0; end

        endcase

    endcase

    // Сохранение опкода
    if (tstate == 0) mopcode <= opcode;

end

endmodule
