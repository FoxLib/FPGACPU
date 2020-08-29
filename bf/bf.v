module bf(

    // Ответ
    input wire          clock,
    input wire [7:0]    prg,         // Входящие данные из программы
    input wire [7:0]    mem,         // Входящие данные из памяти

    // Запрос
    output reg [15:0]   pc,
    output reg [15:0]   cursor,
    output reg [ 7:0]   out,
    output reg          we
);

initial begin

    pc      = 0;
    cursor  = 0;
    out     = 0;
    we      = 0;

end

endmodule
