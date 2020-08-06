module de0(

      /* Reset */
      input              RESET_N,

      /* Clocks */
      input              CLOCK_50,
      input              CLOCK2_50,
      input              CLOCK3_50,
      inout              CLOCK4_50,

      /* DRAM */
      output             DRAM_CKE,
      output             DRAM_CLK,
      output      [1:0]  DRAM_BA,
      output      [12:0] DRAM_ADDR,
      inout       [15:0] DRAM_DQ,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,
      output             DRAM_WE_N,
      output             DRAM_CS_N,
      output             DRAM_LDQM,
      output             DRAM_UDQM,

      /* GPIO */
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

      /* 7-Segment LED */
      output      [6:0]  HEX0,
      output      [6:0]  HEX1,
      output      [6:0]  HEX2,
      output      [6:0]  HEX3,
      output      [6:0]  HEX4,
      output      [6:0]  HEX5,

      /* Keys */
      input       [3:0]  KEY,

      /* LED */
      output      [9:0]  LEDR,

      /* PS/2 */
      inout              PS2_CLK,
      inout              PS2_DAT,
      inout              PS2_CLK2,
      inout              PS2_DAT2,

      /* SD-Card */
      output             SD_CLK,
      inout              SD_CMD,
      inout       [3:0]  SD_DATA,

      /* Switch */
      input       [9:0]  SW,

      /* VGA */
      output      [3:0]  VGA_R,
      output      [3:0]  VGA_G,
      output      [3:0]  VGA_B,
      output             VGA_HS,
      output             VGA_VS
);

// Z-state
assign DRAM_DQ = 16'hzzzz;
assign GPIO_0  = 36'hzzzzzzzz;
assign GPIO_1  = 36'hzzzzzzzz;

// LED OFF
assign HEX0 = 7'b1111111;
assign HEX1 = 7'b1111111;
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;

// -----------------------------------------------------------------------

wire        locked;
reg  [1:0]  locked_rst = 2'b00;

// Ожидание реальной стабилизации данных
always @(posedge CLOCK_50) locked_rst <= {locked_rst[0], locked};

pll u0(
    .clkin      (CLOCK_50),
    .m25        (clk25),
    .m100       (clk),
    .locked     (locked)
);

// Память программ
// -----------------------------------------------------------------------

ram u1(

    .clock      (clk),

    /* Процессор */
    .address_a  (pin_a),
    .q_a        (pin_i),
    .data_a     (pin_o),
    .wren_a     (pin_enw),

    /* Видео */
    .address_b  ({3'b010, video_addr}),
    .q_b        (video_data),

);

// Центральный процессор
// -----------------------------------------------------------------------

wire        pin_enw;
wire [15:0] pin_a;
wire [ 7:0] pin_i;
wire [ 7:0] pin_o;
wire [ 7:0] pin_pa;
wire [ 7:0] pin_pi;
wire [ 7:0] pin_po;
wire        pin_pw;
wire        pin_intr;

kr580 u3(

    /* Шина данных */
    .pin_clk    (clk25 & (locked_rst == 2'b11)),
    .pin_i      (pin_i),
    .pin_a      (pin_a),
    .pin_enw    (pin_enw),
    .pin_o      (pin_o),

    /* Порты */
    .pin_pa     (pin_pa),
    .pin_pi     (pin_pi),
    .pin_po     (pin_po),
    .pin_pw     (pin_pw),
    
    /* Interrupt */
    .pin_intr   (pin_intr)
);

// Видеоадаптер
// ---------------------------------------------------------------------

wire [12:0] video_addr;
wire [ 7:0] video_data;

z80vid u4(

    .clk        (clk25),
    .red        (VGA_R),
    .green      (VGA_G),
    .blue       (VGA_B),
    .hs         (VGA_HS),
    .vs         (VGA_VS),
    .video_addr (video_addr),
    .video_data (video_data),
    .border     (3'b111)

);

endmodule
