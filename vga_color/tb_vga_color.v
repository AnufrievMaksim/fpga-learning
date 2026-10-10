`timescale 1ns / 1ps

module tb_vga_color;

reg clk;
reg reset;
wire hsync, vsync;
wire [3:0] red, green, blue;

// Инстанцирование тестируемого модуля (UUT)
vga_color_bars uut (
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue)
);

// Генерация тактового сигнала 25 МГц (период 40 нс)
initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

// Управление ходом симуляции
initial begin
    // Инициализация файлов для сохранения результатов симуляции (VCD)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_vga_color);

    // Формирование импульса сброса длительностью 100 нс
    reset = 1;
    #100 reset = 0;
    
    // Задание времени симуляции на 1200 тактов
    #(1200 * 40);
    
    $display("Симуляция успешно завершена.");
    $finish;
end

endmodule
