/**
 0 >    i++;                перейти к следующей ячейке
 1 <    i--;                перейти к предыдущей ячейке
 2 +    arr[i]++;           увеличить значение в текущей ячейке на 1
 3 -    arr[i]--;           уменьшить значение в текущей ячейке на 1
 4 .    putchar(arr[i]);    напечатать значение из текущей ячейки
 5 ,    arr[i] = getchar(); ввести извне значение и сохранить в текущей ячейке
 6 [    while(arr[i]) {     если значение текущей ячейки ноль, перейти вперёд по тексту программы на ячейку, следующую за соответствующей ] (с учётом вложенности)
 7 ]    }                   если значение текущей ячейки не нуль, перейти назад по тексту программы на символ [ (с учётом вложенности)
*/

module bf(

    // Ответ
    input wire          clock,
    input wire [3:0]    i_prg,          // Входящие данные из программы
    input wire [7:0]    i_din,          // Входящие данные из памяти
    input wire [7:0]    keyb,           // Данные с клавиатуры (0-если ничего нет)

    // Запрос
    output reg [15:0]   pc,
    output reg [15:0]   cursor,
    output reg [ 7:0]   out,            // Данные для записи
    output reg          we,             // Сигнал записи в память
    output reg          print,          // Сигнал печати `out`
    output reg          kback           // Данные приняты с keyb
);

initial begin

    pc      = 0;
    cursor  = 0;
    out     = 0;
    we      = 0;
    print   = 0;

end

reg        tstate = 0;
reg  [3:0] latch;
reg  [7:0] counter;
wire [3:0] opcode = tstate ? latch : i_prg;

always @(posedge clock) begin

    we    <= 0;
    print <= 0;
    kback <= 0;
    pc    <= pc + 1;

    if (tstate == 0) begin latch <= i_prg; end

    case (opcode)

        /* > */ 0: begin cursor <= cursor + 1; end
        /* < */ 1: begin cursor <= cursor - 1; end
        /* + */ 2: begin out <= i_din + 1; we <= 1; end
        /* - */ 3: begin out <= i_din - 1; we <= 1; end
        /* . */ 4: begin out <= i_din; print <= 1; end
        /* , */ 5: begin if (keyb) begin out <= keyb; we <= 1; kback <= 1; end else pc <= pc; end
        /* [ */ 6: case (tstate) // Если не 0, то перейти к следующей ячейке

            0: begin counter <= 1; if (i_din == 0) tstate <= 1; end
            1: begin

                if      (i_prg == 6) begin counter <= counter + 1; end
                else if (i_prg == 7) begin counter <= counter - 1;
                         if (counter == 1) tstate <= 0;
                end

            end

        endcase
        /* ] */ 7: case (tstate) // Если 0, то перейти к следующей ячейке

            0: begin counter <= 1; if (i_din) begin pc <= pc - 1; tstate <= 1; end end
            1: begin

                pc <= pc - 1;

                if      (i_prg == 7) begin counter <= counter + 1; end
                else if (i_prg == 6) begin counter <= counter - 1;
                         if (counter == 1) begin tstate <= 0; pc <= pc; end
                end

            end

        endcase

    endcase

end

endmodule
