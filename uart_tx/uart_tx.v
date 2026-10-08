`timescale 1ns / 1ps

module tb_uart_tx;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;
wire tx;
wire tx_busy;

parameter CLK_FREQ = 50000000;
parameter BAUD     = 9600;
localparam BIT_TIME = 1000000000 / BAUD;

uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(BAUD)
) uut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    reset = 1;
    tx_start = 0;
    tx_data = 8'h00;
    #100 reset = 0;
    #100;
    
    tx_data = 8'h41;
    tx_start = 1;
    #20 tx_start = 0;
    
    #(10 * BIT_TIME + 1000);
    $finish;
end

endmodule
