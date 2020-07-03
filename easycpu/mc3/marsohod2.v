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
    .c2         (clock_6)       //  6,0 Mhz
);

// --------------------------------------------------------------------------
wire [11:0] font_addr; wire [7:0] font_data;
wire [11:0] char_addr; wire [7:0] char_data;
wire [10:0] cursor = 0;

vga VGA
(
    // Опорная частота
    .CLOCK (clock_25),
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

// #B8000:$B8FFF Видеопамять
videoram VideoMemory
(
    .clock   (clk),
    .addr_rd (char_addr),
    .q       (char_data),
);

// #C0000:$C0FFF Знакогенератор
videofont FontGenerator
(
    .clock   (clk),
    .addr_rd (font_addr),
    .q       (font_data),
);

endmodule
