`timescale 1ns / 1ps

module tb_light;

reg clk;
reg reset;
wire red, yellow, green;

light uut (
    .clk(clk),
    .reset(reset),
    .red(red),
    .yellow(yellow),
    .green(green)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    #20 reset = 0;
    #500 $finish;
end 
    
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_light);
end 
    
endmodule
