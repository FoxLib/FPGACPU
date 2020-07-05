`timescale 10ns / 1ns
module main;
// ---------------------------------------------------------------------
reg clk;
reg clk25;
always #0.5 clk = ~clk;
always #1.5 clk25 = ~clk25;

initial begin clk = 1; clk25 = 0; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end
// ---------------------------------------------------------------------

reg irq_test = 0;
initial #11.5 irq_test = 1;
// ---------------------------------------------------------------------

reg [7:0] memory[65536];
initial $readmemh("program.hex", memory, 16'h0000);

// Контроллер памяти
always @(posedge clk)
begin
    i_data <= memory[o_addr];
    if (o_wren) memory[o_addr] <= o_data;
end

// ---------------------------------------------------------------------
// Процессор
// ---------------------------------------------------------------------

reg  [7:0]  i_data;
wire [7:0]  o_data;
wire [15:0] o_addr;
wire        o_wren;

cpu EasyCPU
(
    .CLOCK  (clk25),
    .I_DATA (i_data),
    .O_ADDR (o_addr),
    .O_DATA (o_data),
    .O_WREN (o_wren),
    // ---
    .IRQ_KEYB (irq_test)
);

endmodule
