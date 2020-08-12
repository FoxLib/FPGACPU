module cpu(

    input   wire        clock,
    output  wire [15:0] address,
    input   wire [ 7:0] i_data,
    output  reg  [ 7:0] o_data,
    output  reg         wren
);

`include "cpu_decl.v"

always @(*) begin

    alu_res  = 8'h00;
    alu_flag = P;

    case (alu)

        alu_ora: alu_res = dst | src;
        alu_and: alu_res = dst & src;
        alu_eor: alu_res = dst ^ src;
        alu_adc: alu_res = dst + src + P[flag_carry];
        alu_sta: alu_res = dst;
        alu_lda: alu_res = src;
        alu_cmp: alu_res = dst - src;
        alu_sbc: alu_res = dst - src - (~P[flag_carry]);

    endcase

end

endmodule
