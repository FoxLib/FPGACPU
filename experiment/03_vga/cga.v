module cga
(
    // Опорная частота
    input   wire        clock_25,

    // Данные из памяти
    input   wire [ 7:0] data,
    output  reg  [17:0] address,

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
    hz_visible = 640, vt_visible = 480,
    hz_front   = 16,  vt_front   = 10,
    hz_sync    = 96,  vt_sync    = 2,
    hz_back    = 48,  vt_back    = 33,
    hz_whole   = 800, vt_whole   = 525;

assign HS = x  < (hz_back + hz_visible + hz_front); // NEG.
assign VS = y >= (vt_back + vt_visible + vt_front); // POS.
// ---------------------------------------------------------------------
wire        xmax = (x == hz_whole - 1);
wire        ymax = (y == vt_whole - 1);
reg  [10:0] x    = 0;
reg  [10:0] y    = 0;
wire [10:0] X    = x - hz_back + 2; // X=[0..639]
wire [ 9:0] Y    = y - vt_back;     // Y=[0..399]
// ---------------------------------------------------------------------

// Цветовая компонента
reg  [7:0] current;
wire [3:0] color = X[0] ? current[3:0] : current[7:4];
reg [11:0] rgb;

// Трансляция индекса в цвет
always @* begin

    case (color)
    4'b0000: rgb = 12'h111; 4'b0001: rgb = 12'h008;
    4'b0010: rgb = 12'h080; 4'b0011: rgb = 12'h088;
    4'b0100: rgb = 12'h800; 4'b0101: rgb = 12'h808;
    4'b0110: rgb = 12'h880; 4'b0111: rgb = 12'hccc;
    4'b1000: rgb = 12'h888; 4'b1001: rgb = 12'h00f;
    4'b1010: rgb = 12'h0f0; 4'b1011: rgb = 12'h0ff;
    4'b1100: rgb = 12'hf00; 4'b1101: rgb = 12'hf0f;
    4'b1110: rgb = 12'hff0; 4'b1111: rgb = 12'hfff;
    endcase

end

always @(posedge clock_25) begin

    // Кадровая развертка
    x <= xmax ?         0 : x + 1;
    y <= xmax ? (ymax ? 0 : y + 1) : y;

    // Вывод окна видеоадаптера
    if (x >= hz_back && x < hz_visible + hz_back &&
        y >= vt_back && y < vt_visible + vt_back)
    begin
         {R, G, B} <= rgb;
    end
    else {R, G, B} <= 12'h000;

    // Чтение и обработка
    case (X[0])

        // 1 байт = 2 точки
        0: begin address <= X[10:1] + Y*320; end

        // Зафиксировать цвета
        1: begin current <= data; end

    endcase

end

endmodule
