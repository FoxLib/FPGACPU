module cga
(
    // Опорная частота
    input   wire        clock_25,

    // Выходные данные
    output  reg  [3:0]  R,      // 4 бит на красный
    output  reg  [3:0]  G,      // 4 бит на зеленый
    output  reg  [3:0]  B,      // 4 бит на синий
    output  wire        HS,     // горизонтальная развертка
    output  wire        VS      // вертикальная развертка
);

// ---------------------------------------------------------------------
// Тайминги для горизонтальной|вертикальной развертки (640x400)
// ---------------------------------------------------------------------

parameter
    hz_visible = 640, vt_visible = 400,
    hz_front   = 16,  vt_front   = 12,
    hz_sync    = 96,  vt_sync    = 2,
    hz_back    = 48,  vt_back    = 35,
    hz_whole   = 800, vt_whole   = 449;

assign HS = x  < (hz_back + hz_visible + hz_front); // NEG.
assign VS = y >= (vt_back + vt_visible + vt_front); // POS.
// ---------------------------------------------------------------------
wire        xmax = (x == hz_whole - 1);
wire        ymax = (y == vt_whole - 1);
reg  [10:0] x    = 0;
reg  [10:0] y    = 0;
wire [10:0] X    = x - hz_back; // X=[0..639]
wire [ 9:0] Y    = y - vt_back; // Y=[0..399]
// ---------------------------------------------------------------------

reg [31:0] rnd = 32'h00000001;

// Следующий бит случайности
wire next_bit = rnd[31] ^ rnd[30] ^ rnd[29] ^ rnd[27] ^ rnd[25] ^ rnd[0];

// Генератор
always @(posedge clock_25) rnd <= { next_bit, rnd[31:1] };

wire [3:0] lv1 = rnd[3:0];
wire [3:0] lv2 = (rnd[3:0]*3)/4;

always @(posedge clock_25) begin

    // Кадровая развертка
    x <= xmax ?         0 : x + 1;
    y <= xmax ? (ymax ? 0 : y + 1) : y;

    // Вывод окна видеоадаптера
    if (x >= hz_back && x < hz_visible + hz_back &&
        y >= vt_back && y < vt_visible + vt_back)
    begin
         {R, G, B} <= Y[0] ? {lv1, lv1, lv1} : {lv2, lv2, lv2};
    end
    else {R, G, B} <= 12'h000;

end

endmodule
