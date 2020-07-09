/**
 * Intel Core [Cryo Kunitsa Edition]
 * А на самом деле полная лажа 8 битная
 */

module core
(
    // Самые главные пины
    input   wire        clock,          // Опорная частота
    output  wire [19:0] address,        // Указатель на текущий адрес
    input   wire [ 7:0] data,           // Входящие данные
    output  reg  [ 7:0] out,            // Исходящие данные
    output  reg         wren            // Разрешение на запись
);

// ---------------------------------------------------------------------
localparam
    sub_opcode = 0;

localparam
    seg_es = 0,
    seg_cs = 1,
    seg_ss = 2,
    seg_ds = 3;

// ---------------------------------------------------------------------
initial begin
    out  = 8'h00;
    wren = 1'b0;
    s[seg_cs] = 16'h0000;
end

// ---------------------------------------------------------------------
assign address = {s[seg_cs], 4'h0} + ip;

// ---------------------------------------------------------------------
reg [ 3:0]  sub     = 0; // Текущая исполняемая процедура
reg [ 7:0]  opcode  = 0;
reg         segment_override = 1'b0;
reg        _segment_override = 1'b0;
reg [ 1:0]  rep = 0;    // Бит 1: Есть ли REP: префикс
reg [ 1:0] _rep = 0;    // Бит 0: 0=RepNZ, 1=RepZ

// Эффективный адрес
reg [15:0]  address_seg = 0;
reg [15:0]  address_eff = 0;
// ---------------------------------------------------------------------
reg [15:0]  r[8];   // Регистры общего назначения
reg [15:0]  s[4];   // Сегменты es: cs: ss: es:
reg [15:0]  ip  = 16'h8000; // "PostBios" загрузка
// ---------------------------------------------------------------------

always @(posedge clock)
begin

    case (sub)

        // ===============================
        // Считывание префиксов и опкода
        // ===============================

        sub_opcode: begin

            ip <= ip + 1;

            casex (data)

                // Загрузка сегмента эффективного адреса
                8'b001x_x110: begin _segment_override <= 1'b1; address_seg <= s[ data[4:3] ]; end
                8'b1111_0000: begin /* lock: */ end
                8'b1111_001x: begin _rep <= data[1:0]; end
                // Другие префиксы опускаются, потому что мне лень реализовывать их
                default: begin

                    // Защелкивание кода инструкции и префикса
                     rep <= _rep;
                    _rep <= 2'b00;
                     segment_override <= _segment_override;
                    _segment_override <= 1'b0;
                    opcode <= data;

                end

            endcase

        end

    endcase

end

endmodule
