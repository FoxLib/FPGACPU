// Разбор опкода и установка метода адресации
INI: begin

    opcode  <= i_data;  // Записать опкод
    implied <= 1'b0;    // Операнд не Implied по умолчанию
    cstate  <= EXE;     // По умолчанию следующий статус EXE
    src_id  <= srcdin;  // Источник операнда - память
    wren    <= 1'b0;    // Отключение записи в память
    read_en <= 1'b1;    // Читать все из памяти (кроме STA)
    o_data  <= A;       // Запись аккумулятора в память

    // Разобрать метод адресации
    casex (i_data)

        8'bxxx_000_x1: cstate <= NDX;
        8'bxxx_010_x1,
        8'b1xx_000_x0: cstate <= EXE; // IMM
        8'bxxx_100_x1: cstate <= NDY;
        8'bxxx_110_x1: cstate <= ABY;
        8'bxxx_0x1_xx: cstate <= ZP;
        8'bxxx_011_xx,
        8'b001_000_00: cstate <= ABS; // JSR
        8'b10x_101_1x: cstate <= ZPY;
        8'bxxx_101_xx: cstate <= ZPX;
        8'b10x_111_1x: cstate <= ABY;
        8'bxxx_111_xx: cstate <= ABX;
        8'bxxx_100_00: cstate <= REL;
        default:       implied <= 1'b1; // ACC, IMP

    endcase

    // Подготовка цикла исполнения опкода
    casex (i_data)

        8'b100_xx_110: /* STX */ begin read_en <= 1'b0; o_data <= X; end
        8'b100_xx_100: /* STY */ begin read_en <= 1'b0; o_data <= Y; end
        8'b100_xxx_01: /* STA */ begin read_en <= 1'b0; end
        8'bxxx_xxx_01: /* ALU */ begin alu     <= i_data[7:5]; end

    endcase

end

// INDIRECT, X ($00,X)
// ---------------------------------------------------------------------
// Вначале рассчитывается 8-битный адрес + регистр X, и из полученного
// адреса считывается 16-битный адрес из области ZeroPage. Например,
// ($55,X) считается $55 + X, из полученного адреса считывается 16-бит
// адрес, который указывает на операнд в памяти.
// ---------------------------------------------------------------------
NDX:   begin cstate <= cpunext; cursor <= i_data_x[7:0];   bus  <= 1'b1;    end
NDX+1: begin cstate <= cpunext; cursor <= nextcursor[7:0]; tmp  <= i_data;  end
NDX+2: begin cstate <= LAT;     cursor <= {i_data, tmp};   read <= read_en; wren <= ~read_en; end

// INDIRECT, Y ($00),Y
// ---------------------------------------------------------------------
// Здесь вначале получаем адрес, из которого из ZeroPage области
// извлекается 16-битный адрес, после чего добавляется Y, и по этому
// адресу уже извлекается операнд
// ---------------------------------------------------------------------
NDY:   begin cstate <= cpunext;   cursor <= i_data;               bus  <= 1'b1; end
NDY+1: begin cstate <= cpunext;   cursor <= nextcursor[7:0];      tmp  <= i_data_y[7:0]; cout <= i_data_y[8]; end
NDY+2: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; read <= read_en;       wren <= ~read_en; end

// ZP, ZPX, ZPY
// ---------------------------------------------------------------------
// Из указанного ZP, ZP+X или ZP+Y адреса получаем из ZeroPage, первых
// 256 байт, нужное значение. Используется как удобная форма
// альтернативных регистров:
//
//  uint8* m = (uint8*) 0
//  uint8  o = m[(адрес + 0|X|Y) & 255]
// ---------------------------------------------------------------------
ZP:    begin cstate <= EXE; cursor <= i_data;        bus <= 1'b1; read <= read_en; wren <= ~read_en; end
ZPX:   begin cstate <= LAT; cursor <= i_data_x[7:0]; bus <= 1'b1; read <= read_en; wren <= ~read_en; end
ZPY:   begin cstate <= LAT; cursor <= i_data_y[7:0]; bus <= 1'b1; read <= read_en; wren <= ~read_en; end

// ABSOLUTE
// ---------------------------------------------------------------------
// Аналогично ZP,ZPX,ZPY, но только меняется то, что теперь указывается
// 16-битный адрес, и получается что используется вся память
//
//  uint8 op8 = mem[ (адрес + 0|X|Y) & 65535 ]
// ---------------------------------------------------------------------
ABS:   begin cstate <= cpunext; tmp <= i_data; pc <= pc + 1;  end
ABS+1: begin // Либо отправляется на jmp (abs), либо используется как опкод

    if (opcode == JMP_ABS)
         begin cstate <= INI; pc     <= {i_data, tmp}; end
    else begin cstate <= EXE; cursor <= {i_data, tmp}; bus <= 1'b1; read <= read_en; wren <= ~read_en; end

end

// ABSOLUTE,X
// ---------------------------------------------------------------------
ABX:   begin cstate <= cpunext;   tmp    <= i_data_x[7:0];        pc  <= pc + 1; cout <= i_data_x[8]; end
ABX+1: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; bus <= 1'b1;   read <= read_en; wren <= ~read_en;  end

// ABSOLUTE,Y
// ---------------------------------------------------------------------
ABY:   begin cstate <= cpunext;   tmp    <= i_data_y[7:0];        pc  <= pc + 1; cout <= i_data_y[8]; end
ABY+1: begin cstate <= lat_state; cursor <= {i_data + cout, tmp}; bus <= 1'b1;   read <= read_en; wren <= ~read_en;  end

// Задержка для симуляции тактов в 6502
LAT:   begin cstate <= EXE; wren <= 1'b0; end
