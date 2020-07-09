module vga
(
    // Опорная частота
    input   wire        CLOCK,

    // Выходные данные
    output  reg  [4:0]  VGA_R,      // 4 бит на красный
    output  reg  [5:0]  VGA_G,      // 4 бит на зеленый
    output  reg  [4:0]  VGA_B,      // 4 бит на синий
    output  wire        VGA_HS,     // горизонтальная развертка
    output  wire        VGA_VS      // вертикальная развертка
);

// ---------------------------------------------------------------------

// Тайминги для горизонтальной развертки (640)
parameter hz_visible = 640;
parameter hz_front   = 16;
parameter hz_sync    = 96;
parameter hz_back    = 48;
parameter hz_whole   = 800;

// Тайминги для вертикальной развертки (400)
parameter vt_visible = 400;
parameter vt_front   = 12;
parameter vt_sync    = 2;
parameter vt_back    = 35;
parameter vt_whole   = 449;

// ---------------------------------------------------------------------
assign VGA_HS = x  < (hz_back + hz_visible + hz_front); // NEG.
assign VGA_VS = y >= (vt_back + vt_visible + vt_front); // POS.
// ---------------------------------------------------------------------

wire        xmax = (x == hz_whole - 1);
wire        ymax = (y == vt_whole - 1);
reg  [10:0] x    = 0;
reg  [10:0] y    = 0;
wire [10:0] X    = x - hz_back; // X=[0..639]
wire [ 9:0] Y    = y - vt_back; // Y=[0..399]

always @(posedge CLOCK) begin

    // Кадровая развертка
    x <= xmax ?         0 : x + 1;
    y <= xmax ? (ymax ? 0 : y + 1) : y;

    // Вывод окна видеоадаптера
    if (x >= hz_back && x < hz_visible + hz_back &&
        y >= vt_back && y < vt_visible + vt_back)
    begin
         {VGA_R, VGA_G, VGA_B} <= {X[4:0], Y[5:0], X[4:0] ^ Y[4:0]};
    end
    else {VGA_R, VGA_G, VGA_B} <= 16'h0000;

end

endmodule
