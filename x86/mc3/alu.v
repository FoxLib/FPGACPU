/**
 * Самый часто используемый модуль в процессоре
 *  0 ADD   4 AND   8 ROL   C SHL
 *  1 OR    5 SUB   9 ROR   D SHR
 *  3 ADC   6 XOR   A RCL   E SHL
 *  4 SBB   7 CMP   B RCR   F SAR
 */

module alu
(
    input  wire [3:0]   alu,
    input  wire [15:0]  op1,
    input  wire [15:0]  op2,
    input  wire         bit16,          // 16-битный операнд
    output reg  [15:0]  result,
    input  wire [11:0]  flags,
    output reg  [11:0]  flags_out
);

`include "localparam.v"

// Некоторые флаги АЛУ
wire zero8  = ~|result[7:0];
wire zero16 = ~|result[15:0];
wire sign8  =   result[7];
wire sign16 =   result[15];
wire parity = ~^result[7:0];

// Специальный случай: переполнение ADD/SUB
wire addof8  = (op1[7]  ^ op2[7]  ^ 1'b1) & (op2[7]  ^ result[7]);
wire addof16 = (op1[15] ^ op2[15] ^ 1'b1) & (op2[15] ^ result[15]);
wire subof8  = (op1[7]  ^ op2[7]        ) & (op2[7]  ^ result[7]);
wire subof16 = (op1[15] ^ op2[15]       ) & (op2[15] ^ result[15]);

always @* begin

    result    = 0;
    flags_out = 0;

    // Результат вычисления
    case (alu)

        /* ADD */ 4'h0: result = op1 + op2;
        /* OR  */ 4'h1: result = op1 | op2;
        /* ADC */ 4'h2: result = op1 + op2 + flags[0];
        /* SBB */ 4'h3: result = op1 - op2 - flags[0];
        /* AND */ 4'h4: result = op1 & op2;
        /* SUB */ 4'h5: result = op1 - op2;
        /* XOR */ 4'h6: result = op1 ^ op2;
        /* CMP */ 4'h7: result = op1 - op2;
        /* ROL */ 4'h8: result = bit16 ? {op1[14:0], op1[15]}   : {op1[6:0], op1[7]};
        /* ROR */ 4'h9: result = bit16 ? {op1[0],    op1[15:1]} : {op1[0],   op1[7:1]};
        /* RCL */ 4'hA: result = bit16 ? {op1[14:0], flags[0]}  : {op1[6:0], flags[0]};
        /* RCR */ 4'hB: result = bit16 ? {flags[0],  op1[15:1]} : {flags[0], op1[7:1]};
        /* SHL */ 4'hC, 4'hE:
                        result = bit16 ? {op1[14:0], 1'b0}      : {op1[6:0], 1'b0};
        /* SHR */ 4'hD: result = bit16 ? {1'b0,      op1[15:1]} : {1'b0,     op1[7:1]};
        /* SAR */ 4'hF: result = bit16 ? {op1[15],   op1[15:1]} : {op1[7],   op1[7:1]};

    endcase

    // Полученные флаги

    case (alu)

        alu_adc,
        alu_adc:

            flags_out = {
                /* 11 OF */ bit16 ? addof16 : addof8,
                /* 10 DF */ flags[10],
                /*  9 IF */ flags[9],
                /*  8 TF */ flags[8],
                /*  7 SF */ bit16 ? sign16 : sign8,
                /*  6 ZF */ bit16 ? zero16 : zero8,
                /*  5  - */ 1'b0,
                /*  4 AF */ op1[3:0] + op2[3:0] + (alu == alu_adc ? flags[0] : 1'b0) >= 5'h10,
                /*  3  - */ 1'b0,
                /*  2 PF */ parity,
                /*  1  - */ 1'b1,
                /*  0 CF */ bit16 ? result[16] : result[8]
            };

        alu_sbb,
        alu_sub,
        alu_cmp:

            flags_out = {
                /* 11 OF */ bit16 ? subof16 : subof8,
                /* 10 DF */ flags[10],
                /*  9 IF */ flags[9],
                /*  8 TF */ flags[8],
                /*  7 SF */ bit16 ? sign16 : sign8,
                /*  6 ZF */ bit16 ? zero16 : zero8,
                /*  5  - */ 1'b0,
                /*  4 AF */ op1[3:0] < op2[3:0] + (alu == alu_sbb ? flags[0] : 1'b0),
                /*  3  - */ 1'b0,
                /*  2 PF */ parity,
                /*  1  - */ 1'b1,
                /*  0 CF */ bit16 ? result[16] : result[8]
            };

        alu_or,
        alu_xor,
        alu_and:

            flags_out = {
                /* 11 OF */ 1'b0,
                /* 10 DF */ flags[10],
                /*  9 IF */ flags[9],
                /*  8 TF */ flags[8],
                /*  7 SF */ bit16 ? sign16 : sign8,
                /*  6 ZF */ bit16 ? zero16 : zero8,
                /*  5  - */ 1'b0,
                /*  4 AF */ result[4], /* Undefined */
                /*  3  - */ 1'b0,
                /*  2 PF */ parity,
                /*  1  - */ 1'b1,
                /*  0 CF */ 1'b0
            };

    endcase

end


endmodule
