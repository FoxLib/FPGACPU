module cpu
(
    input  wire         clock,
    input  wire         locked,

    // Программная память
    output reg  [15:0]  pc,          // Программный счетчик
    input  wire [15:0]  ir,          // Инструкция из памяти

    // Оперативная память
    output reg  [15:0]  address,     // Указатель на память RAM (sram)
    input  wire [ 7:0]  din_raw,     // memory[ address ]
    output reg  [ 7:0]  wb,          // Запись в память по address
    output reg          w            // Разрешение записи в память
);

`include "inc_declare.v"
`include "inc_timer.v"
`include "inc_wbreg.v"

// Исполнительное устройство
always @(posedge clock)
if (locked) begin

    w      <= 1'b0;
    aread  <= 1'b0;
    reg_w  <= 1'b0;
    sreg_w <= 1'b0;
    sp_mth <= 1'b0; // Ничего не делать с SP
    reg_ww <= 1'b0; // Ничего не делать с X,Y,Z
    reg_ws <= 1'b0; // Источник регистр wb2

    if (tstate == 0) latch <= ir;

    // Код пропуска инструкции (JMP, CALL, LDS, STS)
    if (skip_instr) begin

        casex (opcode)

            16'b1001_010x_xxxx_11xx, // CALL | JMP
            16'b1001_00xx_xxxx_0000: // LDS  | STS
                pc <= pcnext + 1;
            default:
                pc <= pcnext;

        endcase

        skip_instr <= 0;

    end

    // Вызов прерывания таймера
    // -----------------------------------------------------------------
    // Таймер вызван
    else if (intr_trigger)
    case (tstate)

        // Запись PCL
        0: begin

            tstate  <= 1;
            address <= sp;
            wb      <= pc[7:0];
            w       <= 1'b1;
            sp_mth  <= `SPDEC;

        end

        // Запись PCH
        1: begin

            tstate  <= 0;
            address <= sp;
            wb      <= pcnext[15:8];
            w       <= 1'b1;
            sp_mth  <= `SPDEC;
            pc      <= 2;           // ISR(INT0_vect)

            // Сброс флага I->0 (sreg)
            alu     <= 11;
            op2     <= {1'b0, sreg[6:0]};
            sreg_w  <= 1'b1;

            // Переход к обычному исполнению
            intr_trigger <= 0;

        end

    endcase

    // Есть истечение времени работы инструкции и вызов таймера
    else if (tstate == 0 && sreg[7] && (timer_ms[7:0] - intr_timer > intr_maxtime)) begin

        intr_trigger <= 1'b1;
        intr_timer   <= timer_ms[7:0];

    end

    // Исполнение опкодов
    else casex (opcode)
    `include "cpu_execute.v"
    endcase

end

endmodule
