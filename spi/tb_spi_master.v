`timescale 1ns / 1ps

module tb_spi_master;

reg clk;
reg reset;
reg start;
reg [7:0] tx_data;
reg miso;
wire sck, mosi, cs;
wire [7:0] rx_data;
wire transfer_done, busy;

// Инстанцирование тестируемого SPI-мастера
spi_master uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .tx_data(tx_data),
    .sck(sck),
    .mosi(mosi),
    .miso(miso),
    .cs(cs),
    .rx_data(rx_data),
    .transfer_done(transfer_done),
    .busy(busy)
);

// Генератор тактового сигнала 50 МГц (период 20 нс)
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// Эмуляция ведомого устройства (отклик значением 0xA5)
initial begin
    miso = 0;
    wait(cs == 0);   
    
    #40;             // Синхронизация с первым перепадом мастера
    miso = 1; #80;   // Выдача D7
    miso = 0; #80;   // Выдача D6
    miso = 1; #80;   // Выдача D5
    miso = 0; #80;   // Выдача D4
    miso = 0; #80;   // Выдача D3
    miso = 1; #80;   // Выдача D2
    miso = 0; #80;   // Выдача D1
    miso = 1; #80;   // Выдача D0
end

// Управление ходом тестирования
initial begin
    // Настройка сохранения сигналов для генерации временной диаграммы (EPWave)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_spi_master);
    
    // Начальный сброс системы
    reset = 1;
    start = 0;
    tx_data = 8'h00;
    
    #100 reset = 0;
    #100;
    
    // Инициализация передачи байта 0x5A
    tx_data = 8'h5A;
    start = 1;
    #20 start = 0; // Импульс запуска длительностью 1 системный такт
    
    // Ожидание флага окончания операции
    wait(transfer_done == 1);
    #100;
    
    // Вывод лога в консоль симулятора
    $display("=========================================");
    $display("SPI Master Test");
    $display("=========================================");
    $display("Отправлено:  0x5A");
    $display("Принято:     0x%h", rx_data);
    $display("Ожидалось:   0xA5");
    $display("=========================================");
    
    $finish;
end

endmodule
