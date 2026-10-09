`timescale 1ns / 1ps

module tb_uart_loopback;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;

wire [7:0] rx_data;
wire rx_done;
wire tx_busy;
wire rx_busy;

// Подключение модуля Loopback
uart_loopback uut (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_busy(tx_busy),
    .rx_busy(rx_busy)
);

// Генератор такта 50 МГц (период 20 нс)
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// Тестовый сценарий
initial begin
    // Настройки графиков для EDA Playground
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_loopback);

    reset = 1;
    tx_start = 0;
    tx_data = 8'h00;
    
    #100 reset = 0; // Отпускаем сброс
    #100;
    
    // Отправка байта 0x41 (Буква 'A')
    tx_data = 8'h41;
    tx_start = 1;
    #20 tx_start = 0; 
    
    // Ожидание: симулятор ждет импульса готовности от приемника
    wait(rx_done == 1);
    #100; 
    
    $finish;
end

endmodule
