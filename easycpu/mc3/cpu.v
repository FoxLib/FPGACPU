module cpu
(
    input  wire         CLOCK,      // Типичная частота 25 Мгц
    input  wire [ 7:0]  I_DATA,     // =memory[O_ADDR]
    output wire [15:0]  O_ADDR,     // Запрос в память
    output reg  [ 7:0]  O_DATA,     // Данные на запись
    output reg          O_WREN      // Разрешение записи
);

// ---------------------------------------------------------------------
assign  O_ADDR = alt ? address : ip; // Указатель в память | текущий ip
// ---------------------------------------------------------------------
initial O_WREN = 1'b0;
initial O_DATA = 8'h00;
initial r[ 2]  = 16'h0001;
initial r[15]  = 16'h0000;
// ---------------------------------------------------------------------
reg         alt      = 0;           // 0-IP, 1-Address
reg [15:0]  ip       = 16'h0000;
reg [15:0]  address  = 16'h0000;
reg [ 7:0]  mopcode  = 8'h00;       // Сохраненный опкод
reg [ 2:0]  tstate   = 3'h0;        // Состояние исполнения инструкции
reg [15:0]  tmp      = 16'h0000;
// ---------------------------------------------------------------------
reg [15:0]  r[16];                  // 16 регистров процессора 256 bit
reg [15:0]  acc      = 16'h0002;    // Аккумулятор
reg         cf       = 1'b0;        // Carry Flag
reg         zf       = 1'b0;        // Zero Flag
// ---------------------------------------------------------------------
wire [7:0]  opcode   = tstate? mopcode : I_DATA; // Текущий опкод
wire [15:0] regin    = r[ opcode[3:0] ];
wire [16:0] alu_add  = acc + regin;
wire [16:0] alu_sub  = acc - regin;
wire [15:0] alu_and  = acc & regin;
wire [15:0] alu_xor  = acc ^ regin;
wire [15:0] alu_ora  = acc | regin;
// ---------------------------------------------------------------------

wire [15:0] __r = r[15];

always @(posedge CLOCK) begin

    tstate <= tstate + 1;

    // Исполнение инструкции
    casex (opcode)

        // 0x LDI Rn, **
        8'b0000_xxxx: case (tstate)

            0: begin tstate <= 1; ip <= ip + 1; end
            1: begin tstate <= 2; ip <= ip + 1; tmp[7:0] <= I_DATA; end
            2: begin r[ opcode[3:0] ] <= {I_DATA, tmp[7:0]}; ip <= ip + 1; tstate <= 0; end

        endcase

        // 10 LDA [**]
        8'b0001_0000: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; address[ 7:0] <= I_DATA; end
            2: begin ip <= ip + 1; address[15:8] <= I_DATA; alt <= 1; end
            3: begin acc[ 7:0] <= I_DATA; address <= address + 1; end
            4: begin tstate <= 0; acc[15:8] <= I_DATA; alt <= 0; end

        endcase

        // 11 STA [**]
        8'b0001_0001: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; address[ 7:0] <= I_DATA; end
            2: begin ip <= ip + 1; address[15:8] <= I_DATA; alt <= 1; O_DATA <= acc[7:0]; O_WREN <= 1'b1; end
            3: begin O_DATA <= acc[15:8]; address <= address + 1; end
            4: begin tstate <= 0; alt <= 0; O_WREN <= 1'b0; end

        endcase

        // 12 SHR
        8'b0001_0010: begin acc <= {1'b0, acc[7:1]}; cf <= acc[0]; zf = ~|acc[7:1]; ip <= ip + 1; tstate <= 0; end

        // 13 LDA **
        8'b0001_0011: case (tstate)

            0: begin ip <= ip + 1; end
            1: begin ip <= ip + 1; acc[7:0]  <= I_DATA; end
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

        // 16 RET
        8'b0001_0110: case (tstate)

            0: begin address <= r[15]; r[15] <= r[15] + 2; alt <= 1; end
            1: begin ip[ 7:0] <= I_DATA; address <= address + 1; end
            2: begin ip[15:8] <= I_DATA; tstate <= 0; alt <= 0; end

        endcase

        // 17 BRK ==> Полная остановка процессора
        8'b0001_0111: begin tstate <= 0; end

        // 2x LDA [Rn] Загрузка 16-битных данных по адресу Rn
        8'b0010_xxxx: case (tstate)

            0: begin address <= regin; alt <= 1'b1; ip <= ip + 1; end
            1: begin address <= address + 1'b1; acc[7:0] <= I_DATA; end
            2: begin acc[15:8] <= I_DATA; alt <= 0; tstate <= 0; end

        endcase

        // 3x STA [Rn] Выгрузка младших 8 бит по адресу Rn
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

        // Cx INC Rn | Dx DEC Rn
        8'b1100_xxxx: begin r[opcode[3:0]] <= regin + 1; zf <= regin == 16'hFFFF; ip <= ip + 1; tstate <= 0; end
        8'b1101_xxxx: begin r[opcode[3:0]] <= regin - 1; zf <= regin == 16'h0001; ip <= ip + 1; tstate <= 0; end

    endcase

    // Сохранение опкода
    if (tstate == 0) mopcode <= opcode;

end

endmodule
