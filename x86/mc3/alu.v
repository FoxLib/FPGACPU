/**
 * Самый часто используемый модуль в процессоре
 *  0 ADD   4 AND   8 ROL   C SHL
 *  1 OR    5 SUB   9 ROR   D SHR
 *  3 ADC   6 XOR   A RCL   E SHL
 *  4 SBB   7 CMP   B RCR   F SAR
 */

module alu
(
    input wire [3:0]    alu,
    input wire [15:0]   op1,
    input wire [15:0]   op2,
    input wire          bit16,          // 16-битный операнд
    output reg [15:0]   result,
    input wire [11:0]   flags,
    output reg [11:0]   flags_out
);

/*

// Некоторые флаги АЛУ
wire Zero8  = ~|Ar[7:0];
wire Zero16 = ~|Ar[15:8] && Zero8;
wire Sign8  =   Ar[7];
wire Sign16 =   Ar[15];
wire Parity = ~^Ar[7:0];

// Специальный случай: переполнение ADD/SUB
wire ADD_Overflow8  = (op1[7]  ^ op2[7]  ^ 1'b1) & (op2[7]  ^ Ar[7]);
wire ADD_Overflow16 = (op1[15] ^ op2[15] ^ 1'b1) & (op2[15] ^ Ar[15]);
wire SUB_Overflow8  = (op1[7]  ^ op2[7]        ) & (op2[7]  ^ Ar[7]);
wire SUB_Overflow16 = (op1[15] ^ op2[15]       ) & (op2[15] ^ Ar[15]);
*/

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

end


endmodule
