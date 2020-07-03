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
initial r[2]   = 16'h0001;
// ---------------------------------------------------------------------
reg         alt      = 0;           // 0-IP, 1-Address
reg [15:0]  ip       = 16'h0000;
reg [15:0]  address  = 16'h0000;
reg [ 7:0]  mopcode  = 8'h00;       // Сохраненный опкод
reg [ 2:0]  tstate   = 3'h0;        // Состояние исполнения инструкции
reg [ 7:0]  tmp      = 8'h00;       // Временное хранение
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

wire [15:0] __r = r[2];

always @(posedge CLOCK) begin

    // Исполнение инструкции
    casex (opcode)

        // 0x LDI Rn, **
        8'b0000_xxxx: case(tstate)

            0: begin tstate <= 1; ip <= ip + 1; end
            1: begin tstate <= 2; ip <= ip + 1; tmp <= I_DATA; end
            2: begin r[ opcode[3:0] ] <= {I_DATA, tmp}; ip <= ip + 1; tstate <= 0; end

        endcase

        // 2x LDA [Rn] Загрузка 16-битных данных по адресу Rn
        8'b0010_xxxx: case (tstate)

            0: begin tstate <= 1; address <= regin; alt <= 1'b1; ip <= ip + 1; end
            1: begin tstate <= 2; address <= address + 1'b1; acc[7:0] <= I_DATA; end
            2: begin acc[15:8] <= I_DATA; alt <= 0; tstate <= 0; end

        endcase

        // 3x STA [Rn] Выгрузка младших 8 бит по адресу Rn
        8'b0011_xxxx: case (tstate)

            0: begin tstate <= 1; address <= regin; alt <= 1'b1; O_WREN <= 1; O_DATA <= acc[7:0]; ip <= ip + 1; end
            1: begin tstate <= 0; alt <= 0; O_WREN <= 0; end

        endcase

        // 4x LDA Rn
        // 5x STA Rn
        8'b0100_xxxx: begin acc <= regin; ip <= ip + 1; end
        8'b0101_xxxx: begin r[opcode[3:0]] <= acc; ip <= ip + 1; end

        // 6x ADD Rn | 7x SUB Rn | 9x AND Rn | Ax XOR Rn | Bx ORA Rn
        8'b0110_xxxx: begin acc <= alu_add[15:0]; cf <= alu_add[16]; zf = ~|alu_add[15:0]; ip <= ip + 1; end
        8'b0111_xxxx: begin acc <= alu_sub[15:0]; cf <= alu_sub[16]; zf = ~|alu_sub[15:0]; ip <= ip + 1; end
        8'b1001_xxxx: begin acc <= alu_and[15:0]; zf = ~|alu_and[15:0]; ip <= ip + 1; end
        8'b1010_xxxx: begin acc <= alu_xor[15:0]; zf = ~|alu_xor[15:0]; ip <= ip + 1; end
        8'b1011_xxxx: begin acc <= alu_ora[15:0]; zf = ~|alu_ora[15:0]; ip <= ip + 1; end

        // Cx INC Rn | Dx DEC Rn
        8'b1100_xxxx: begin r[opcode[3:0]] <= regin + 1; zf <= regin == 16'hFFFF; ip <= ip + 1; end
        8'b1101_xxxx: begin r[opcode[3:0]] <= regin - 1; zf <= regin == 16'h0001; ip <= ip + 1; end

    endcase

    // Сохранение опкода
    if (tstate == 0) mopcode <= opcode;

end

endmodule
