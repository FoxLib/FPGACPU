
// ---------------------------------------------------------------------
// Считывание префиксов и опкода
// ---------------------------------------------------------------------

sub_opcode: begin

    ip   <= ip + 1;
    wren <= 1'b0;

    casex (data)

        // Загрузка сегмента эффективного адреса
        8'b001x_x110: begin _override <= 1'b1; _seg <= s[ data[4:3] ]; end
        8'b0000_1111: begin  sub <= sub_extended; end
        8'b1111_0000: begin /* lock: */ end
        8'b1111_001x: begin _rep <= data[1:0]; end

        // Другие префиксы опускаются, потому что мне лень реализовывать их
        default: begin

            // Защелкивание кода инструкции и префикса
             rep   <= _rep;   override <= _override;  seg <= _seg;
            _rep   <= 2'b00; _override <= 1'b0;      _seg <= s[seg_ds];
            fn     <= 1'b0;
            fn2    <= 1'b0;
            bit16  <= 1'b0;
            dir    <= 1'b0;
            opcode <= data;

            // Декодирование опкода
            casex (data)

                // Инструкции ADD|ADC|SUB|SBB|AND|XOR|OR|CMP <modrm>|Acc,i8/16
                8'b00_xxx_0xx: begin sub <= sub_modrm; alu <= data53; bit16 <= data[0]; dir <= data[1]; end
                8'b00_xxx_10x: begin sub <= sub_exec;  alu <= data53; bit16 <= data[0]; end

                // INC|DEC r16
                8'b01_00x_xxx: begin sub <= sub_exec;  alu <= data[3] ? alu_sub : alu_add; bit16 <= 1'b1;
                                     op1 <= r[data20]; op2 <= 1'b1; end
                // PUSH r16
                // PUSH sreg
                8'b000_xx_110,
                8'b01_010_xxx: begin sub <= sub_exec;  wren <= 1'b1;
                                     seg <= s[seg_ss]; eff  <= r[reg_sp] - 2;
                                     swi <= 1'b1;      out  <= data[6] ? r[data20][7:0] : s[data[4:3]][7:0]; end
                // POP r16
                // POP sreg
                8'b000_xx_111,
                8'b01_011_xxx: begin sub <= sub_exec;  r[reg_sp] <= r[reg_sp] + 2;
                                     seg <= s[seg_ss]; eff <= r[reg_sp]; swi <= 1'b1; end

                // XCHG AX, r16
                8'b1001_0_xxx: begin r[reg_ax] <= r[data20]; r[data20] <= r[reg_ax]; end

                // J<cond> +d8
                8'b01_11x_xxx: if (condition[data[3:1]] ^ data[0]) sub <= sub_exec; else ip <= ip + 2;

                // HLT, CMC
                8'b1111_0100: ip <= ip;
                8'b1111_0101: flags[flag_c] <= ~flags[flag_c];

                // CLC, STC, CLI, STI, CLD, STD
                8'b1111_100x: flags[flag_c] <= data[0];
                8'b1111_101x: flags[flag_i] <= data[0];
                8'b1111_110x: flags[flag_d] <= data[0];

                // Все остальные инструкции, не требующие первого такта
                default: sub <= sub_exec;

            endcase

        end

    endcase

end
