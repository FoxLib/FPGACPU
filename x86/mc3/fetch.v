
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
                8'b01_010_xxx: begin sub <= sub_exec;  wren <= 1'b1;
                                     seg <= s[seg_ss]; eff  <= r[reg_sp] - 2;
                                     swi <= 1'b1;      out  <= r[data20][7:0]; end
                // POP r16
                8'b01_011_xxx: begin sub <= sub_exec;  r[reg_sp] <= r[reg_sp] + 2;
                                     seg <= s[seg_ss]; eff <= r[reg_sp]; swi <= 1'b1; end

                // J<cond> +d8
                8'b01_11x_xxx: if (condition[data[3:1]] ^ data[0]) sub <= sub_exec; else ip <= ip + 2;

                // Все остальные инструкции, не требующие первого такта
                default: sub <= sub_exec;

            endcase

        end

    endcase

end
