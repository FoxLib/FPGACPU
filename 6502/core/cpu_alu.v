// Запрос и результат
reg  [ 3:0] alu = 4'h0;
wire [ 7:0] dst; // Обычно аккумулятор
wire [ 7:0] src; // Данные

// Результаты
reg  [ 8:0] alu_res  = 8'h0;
reg  [ 7:0] alu_flag = 8'h0;

assign dst = dst_id == DSTA ? A :
             dst_id == DSTX ? X :
             dst_id == DSTY ? Y : S;

// Источник операндов
assign src = src_id == SRCDIN ? i_data :
             src_id == SRCX   ? X :
             src_id == SRCY   ? Y : 8'hFF;

// ---------------------------------------------------------------------

// Статусы ALU
wire cin   =   P[0];
wire zero  = ~|alu_res[7:0];    // Флаг нуля
wire sign  =   alu_res[7];      // Знак
wire carry =   alu_res[8];

// Флаг переполнения
wire adc_o = (dst[7] ^ src[7] ^ 1'b1) & (dst[7] ^ alu_res[7]);
wire sbc_o = (dst[7] ^ src[7] ^ 1'b0) & (dst[7] ^ alu_res[7]);

always @(*) begin

    alu_res  = 0;
    alu_flag = P;

    // Расчет результатов
    case (alu)

        // Арифметическо-логические
        alu_ora: alu_res = dst | src;
        alu_and: alu_res = dst & src;
        alu_eor: alu_res = dst ^ src;
        alu_adc: alu_res = dst + src + cin;
        alu_sta: alu_res = dst;
        alu_lda: alu_res = src;
        alu_cmp: alu_res = dst - src;
        alu_sbc: alu_res = dst - src - !cin;

        // Сдвиги и прочие
        alu_asl: alu_res = {src[6:0], 1'b0};
        alu_rol: alu_res = {src[6:0], cin};
        alu_lsr: alu_res = {1'b0, src[7:1]};
        alu_ror: alu_res = {cin,  src[7:1]};
        alu_bit: alu_res = dst & src;
        alu_dec: alu_res = src - 1;
        alu_inc: alu_res = src + 1;

    endcase

    // Расчет флагов
    casex (alu)

        // Арифметико-логика
        alu_ora, alu_and, alu_eor, alu_sta, alu_lda, alu_dec, alu_inc:
                 alu_flag = {sign, P[6:2], zero, cin};
        alu_adc: alu_flag = {sign, adc_o, P[5:2], zero,  carry};
        alu_sbc: alu_flag = {sign, sbc_o, P[5:2], zero, ~carry};
        alu_cmp: alu_flag = {sign, P[6:2], zero, ~carry};

        // Сдвиговые
        alu_asl, alu_rol: alu_flag = {sign, P[6:2], zero, src[7]};
        alu_lsr, alu_ror: alu_flag = {sign, P[6:2], zero, src[0]};
        alu_bit:          alu_flag = {src[7:6], P[5:2], zero, cin};

        // Флаговые
        alu_flg: casex (opcode[7:5])

            /* CLC */ 3'b00x: alu_flag = {P[7:1], opcode[5]};
            /* CLI */ 3'b01x: alu_flag = {P[7:3], opcode[5], P[1:0]};
            /* CLV */ 3'b101: alu_flag = {P[7],   1'b0,      P[5:0]};
            /* CLD */ 3'b11x: alu_flag = {P[7:4], opcode[5], P[2:0]};

        endcase

    endcase

end
