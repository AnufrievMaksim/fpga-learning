`timescale 1ns / 1ps

module tb_pwm;

reg clk;
reg reset;
reg [7:0] duty;
wire pwm_out;

// Подключение тестируемого модуля (UUT)
pwm uut (
    .clk(clk),
    .reset(reset),
    .duty(duty),
    .pwm_out(pwm_out)
);

// Генератор тактовой частоты (период 10 нс, инверсия каждые 5 нс)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Тестовый сценарий
initial begin
    // Настройки для генерации графиков в EDA Playground
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_pwm);

    // Инициализация сигналов и сброс
    reset = 1;
    duty = 8'd0;
    #20 reset = 0; // Отпускаем сброс через 20 нс
    
    // Сценарий 1: Скважность 25% (яркость четверть от максимума)
    duty = 8'd64;
    #3000; // Ждем чуть больше одного полного цикла ШИМ (2560 нс)
    
    // Сценарий 2: Скважность 50% (ровно половина яркости)
    duty = 8'd128;
    #3000;
    
    // Сценарий 3: Скважность 75% (три четверти яркости)
    duty = 8'd192;
    #3000;
    
    $finish; // Завершение симуляции
end

endmodule
