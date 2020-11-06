module cga
(
    // Опорная частота
    input   wire        clock_25,

    // Выходные данные
    output  reg  [3:0]  R,      // 4 бит на красный
    output  reg  [3:0]  G,      // 4 бит на зеленый
    output  reg  [3:0]  B,      // 4 бит на синий
    output  wire        HS,     // горизонтальная развертка
    output  wire        VS,     // вертикальная развертка

    input  wire [3:0]   KEY
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

reg  [23:0] cnt;

reg  [9:0] player_left  = 200-32;
reg  [9:0] player_right = 0;

// Положение и направление шарика
reg [10:0] ball_x = 320; reg  ball_dx = 1'b1;
reg [ 9:0] ball_y = 200; reg  ball_dy = 1'b1;

// Проверка наличия объектов в текущей рисуемой точке
wire is_player_left  = (X <  16) && (player_left  <= Y && Y < player_left  + 64);
wire is_player_right = (X > 624) && (player_right <= Y && Y < player_right + 64);
wire is_ball         = (X - ball_x)*(X - ball_x) + (Y - ball_y)*(Y - ball_y) < 16;

// Вычисление
always @(posedge clock_25) begin

    if (cnt == 250000) begin

        cnt <= 0;

        // -------------------------------------------------------------

        // Компьютер управляет игроком
        if (ball_y < player_right + 16 && player_right)
            player_right <= player_right - 1;
        else if (ball_y > player_right + 48 && player_right < 400-64)
            player_right <= player_right + 1;

        // -------------------------------------------------------------

        // Правый игрок
        if (ball_dx) begin

            // Отбил
            if (player_right <= ball_y && ball_y < player_right + 64 && ball_x >= 640 - 16)
                ball_dx <= 0;
            // Проигрыш игрока
            else if (ball_x >= 640-4)
                ball_dx <= 0;
            else
                ball_x <= ball_x + 1;

        end
        // Левый игрок
        else begin

            // Отбил
            if (player_left <= ball_y && ball_y < player_left + 64 && ball_x <= 16)
                ball_dx <= 1; // @todo рандомная сторона Y
            // Проигрыш
            else if (ball_x <= 4)
                ball_dx <= 1;
            else
                ball_x <= ball_x - 1;
        end

        // -------------------------------------------------------------

        // Отбивание по высоте
        if (ball_dy) begin
            if (ball_y >= 400-4) ball_dy <= 0; else ball_y <= ball_y + 1;
        end else begin
            if (ball_y <= 4) ball_dy <= 1; else ball_y <= ball_y - 1;
        end

        // -------------------------------------------------------------

        // Управление
        if (KEY[1] && player_left)               player_left <= player_left - 1;
        else if (KEY[0] && player_left < 400-64) player_left <= player_left + 1;

    end
    else cnt <= cnt + 1;

end

// Отображение
always @(posedge clock_25) begin

    // Кадровая развертка
    x <= xmax ?         0 : x + 1;
    y <= xmax ? (ymax ? 0 : y + 1) : y;

    // Вывод окна видеоадаптера
    if (x >= hz_back && x < hz_visible + hz_back &&
        y >= vt_back && y < vt_visible + vt_back)
    begin

        if (is_player_left)       {R, G, B} <= 12'h0F0;
        else if (is_player_right) {R, G, B} <= 12'h0FF;
        else if (is_ball)         {R, G, B} <= 12'hFFF;
        else {R, G, B} <= 12'h111;

    end
    else {R, G, B} <= 12'h000;

end

endmodule
