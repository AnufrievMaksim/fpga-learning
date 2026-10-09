`timescale 1ns / 1ps

module tb_uart_rx;

reg clk;
reg reset;
reg rx;
wire [7:0] rx_data;
wire rx_done;
wire rx_busy;

// Параметры
parameter CLK_FREQ = 50000000;
parameter BAUD     = 9600;
localparam BIT_TIME = 1000000000 / BAUD;  // время бита в нс

// Подключение тестируемого модуля (UUT)
uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(BAUD)
) uut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .rx_busy(rx_busy)
);

// Генератор такта 50 МГц (период 20 нс)
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// Виртуальный передатчик (задача send_byte)
task send_byte(input [7:0] data);
    integer i;
    begin
        rx = 0;                  // START-бит (роняем в 0)
        #(BIT_TIME);
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];        // Выдаем биты (младший вперед)
            #(BIT_TIME);
        end
        rx = 1;                  // STOP-бит (возвращаем в 1)
        #(BIT_TIME);
    end
endtask

// Тестовый сценарий
initial begin
    // Настройки для вывода графиков в EDA Playground
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_uart_rx);

    reset = 1;
    rx = 1; // В покое линия всегда 1
    #100 reset = 0;
    #100;
    
    // Передаем в приемник байт 0x41 ('A')
    send_byte(8'h41);
    #1000;
    
    $finish;
end

endmodule
