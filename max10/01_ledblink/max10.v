module max10(

    output wire [13:0]   IO,
    output wire [ 3:0]   LED,
    input  wire          KEY0,
    input  wire          KEY1,
    input  wire          SERIAL_RX,
    input  wire          SERIAL_TX,
    input  wire          CLK100MHZ
);

assign LED = cnt[29:26];

integer cnt;

always @(posedge CLK100MHZ)
    cnt <= cnt + 1;


endmodule
