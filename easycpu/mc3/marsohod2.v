module marsohod2(

    /* ----------------
     * Archectural Marsohod2
     * ---------------- */

    // CLOCK    100 Mhz
    input   wire        clk,

    // LED      4
    output  wire [3:0]  led,

    // KEYS     2
    input   wire [1:0]  keys,

    // ADC      8 bit
    output  wire        adc_clock_20mhz,
    input   wire [7:0]  adc_input,

    // SDRAM
    output  wire        sdram_clock,
    output  wire [11:0] sdram_addr,
    output  wire [1:0]  sdram_bank,
    inout   wire [15:0] sdram_dq,
    output  wire        sdram_ldqm,
    output  wire        sdram_udqm,
    output  wire        sdram_ras,
    output  wire        sdram_cas,
    output  wire        sdram_we,

    // VGA
    output  wire [4:0]  vga_red,
    output  wire [5:0]  vga_green,
    output  wire [4:0]  vga_blue,
    output  wire        vga_hs,
    output  wire        vga_vs,

    // FTDI (PORT-B)
    input   wire        ftdi_rx,
    output  wire        ftdi_tx,

    /* ----------------
     * Extension Shield
     * ---------------- */

    // USB-A    2 pins
    inout   wire [1:0]  usb,

    // SOUND    2 channel
    output  wire        sound_left,
    output  wire        sound_right,

    // PS/2     keyb / mouse
    inout   wire [1:0]  ps2_keyb,   // ps2_keyb[0] = DAT,   ps2_mouse[0] = DAT
    inout   wire [1:0]  ps2_mouse   // ps2_keyb[1] = CLK,   ps2_mouse[0] = CLK
);
// --------------------------------------------------------------------------

pll PLL(

    .clk        (clk),          // Входящие 100 Мгц
    .locked     (locked),       // 1 - готово и стабильно
    .c0         (clock_25),     // 25,0 Mhz
    .c1         (clock_12),     // 12,0 Mhz
    .c2         (clock_6),      //  6,0 Mhz
    .c3         (clock_50)      // 50,0 Mhz
);


// ---------------------------------------------------------------------
// Видеоадаптер
// ---------------------------------------------------------------------
wire [11:0] font_addr; wire [7:0] font_data;
wire [11:0] char_addr; wire [7:0] char_data;
wire [10:0] cursor = 0;
wire [7:0]  qw_videoram;
wire [7:0]  qw_videofont;
wire [7:0]  qw_prgram;

vga VGA
(
    // Опорная частота
    .CLOCK  (clock_25),
    // Выходные данные
    .VGA_R  (vga_red),
    .VGA_G  (vga_green),
    .VGA_B  (vga_blue),
    .VGA_HS (vga_hs),
    .VGA_VS (vga_vs),
    // Знакогенератор
    .FONT_ADDR  (font_addr),
    .FONT_DATA  (font_data),
    .CHAR_ADDR  (char_addr),
    .CHAR_DATA  (char_data),
    // Управление
    .CURSOR     (cursor)
);

// #F000:$FFFF Видеопамять
// ---------------------------------------------------------------------
videoram VideoMemory
(
    .clock   (clk),
    .addr_rd (char_addr),
    .q       (char_data),
    .addr_wr (o_addr[11:0]),
    .data_wr (o_data),
    .qw      (qw_videoram),
    .wren    (o_wren & wren_videoram),
);

// #E000:$EFFF Знакогенератор
// ---------------------------------------------------------------------
videofont FontGenerator
(
    .clock   (clk),
    .addr_rd (font_addr),
    .q       (font_data),
    .addr_wr (o_addr[11:0]),
    .data_wr (o_data),
    .qw      (qw_videofont),
    .wren    (o_wren & wren_videofont),
);

// #0000:$7FFF Память программ
// ---------------------------------------------------------------------
prgram ProgramMemory
(
    .clock   (clk),
    .addr_wr (o_addr[14:0]),
    .data_wr (o_data),
    .qw      (qw_prgram),
    .wren    (o_wren & wren_prgram),
);

// ---------------------------------------------------------------------
// Контроллер клавиатуры
// ---------------------------------------------------------------------

reg  [7:0] keybxt;
reg  [7:0] keybcnt;
wire [7:0] ps2data;

ps2keyboard keyb
(
    .CLOCK_50           (clock_50),    // Тактовый генератор на 50 Мгц
    .PS2_CLK            (ps2_keyb[1]), // Таймингс PS/2
    .PS2_DAT            (ps2_keyb[0]), // Данные с PS/2
    .received_data      (ps2data),     // Принятые данные
    .received_data_en   (ps2hit),      // Нажата клавиша
);

// Прием символа (пример)
always @(posedge clock_50)
if (ps2hit) begin keybxt <= ps2data; keybcnt <= keybcnt + 1; end

// ---------------------------------------------------------------------
// Контроллер памяти
// ---------------------------------------------------------------------

reg [7:0]   i_data;
reg         wren_prgram;
reg         wren_videoram;
reg         wren_videofont;

always @* begin

    i_data          = 0;
    wren_videoram   = 0;
    wren_videofont  = 0;

    // Выборка памяти
    casex (o_addr)

        16'hFFA0: i_data = keybxt[7:0]; // Нажатая клавиша AT
        16'hFFA1: i_data = keybcnt;     // Счетчик нажатых клавиш
        16'b0xxx_xxxx_xxxx_xxxx: begin i_data = qw_prgram;    wren_prgram    = 1'b1; end
        16'b1110_xxxx_xxxx_xxxx: begin i_data = qw_videofont; wren_videofont = 1'b1; end
        16'b1111_xxxx_xxxx_xxxx: begin i_data = qw_videoram;  wren_videoram  = 1'b1; end

    endcase

end

// ---------------------------------------------------------------------
// Микропроцессор
// ---------------------------------------------------------------------

wire [15:0] o_addr;
wire [ 7:0] o_data;
wire        o_wren;

cpu EasyCPU
(
    .CLOCK      (locked & clock_25),
    .I_DATA     (i_data),
    .O_ADDR     (o_addr),
    .O_DATA     (o_data),
    .O_WREN     (o_wren),
);

endmodule
