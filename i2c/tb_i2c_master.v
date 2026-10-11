`timescale 1ns / 1ps

module tb_i2c_master;

reg clk;
reg reset;
reg start;
reg [6:0] addr;
reg [7:0] data;
wire sda, scl;
wire done, busy;

// Инстанцирование тестируемого I2C-мастера (UUT)
i2c_master uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .addr(addr),
    .data(data),
    .sda(sda),
    .scl(scl),
    .done(done),
    .busy(busy)
);

// Генератор тактового сигнала 10 МГц (период 100 нс)
initial begin
    clk = 0;
    forever #50 clk = ~clk;
end

// Формирование тестового сценария
initial begin
    // Настройка сохранения сигналов для генерации временной диаграммы (EPWave)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_i2c_master);

    // Инициализация исходных состояний
    reset = 1;
    start = 0;
    addr = 7'h62;  // Базовый адрес ведомого устройства MCP4725
    data = 8'hAB;  // Тестовый байт данных для передачи
    
    // Снятие сигнала сброса через 200 нс
    #200 reset = 0;
    #200;
    
    // Формирование импульса запуска длительностью 100 нс
    start = 1;
    #100 start = 0;
    
    // Ожидание фиксации флага окончания передачи кадра
    wait(done == 1);
    #1000;
    
    // Вывод лога окончания теста и завершение симуляции
    $display("I2C передача завершена");
    $finish;
end

endmodule


