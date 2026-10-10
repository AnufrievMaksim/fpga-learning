`timescale 1ns / 1ps

module tb_vga;

reg clk;
reg reset;
wire hsync, vsync, video_on;
wire [9:0] x, y;

// Сигналы цвета для монитора (3 бита на Red, Green, Blue)
reg [2:0] r, g, b;

vga_controller uut (
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .x(x),
    .y(y),
    .video_on(video_on)
);

// Генератор тактовой частоты 25 МГц (период 40 нс)
initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

// Генерация тестового рисунка на основе координат x и y
always @(*) begin
    if (!video_on) begin
        // Вне экрана цвета должны быть строго нулями (черный)
        r = 3'b000; g = 3'b000; b = 3'b000;
    end else begin
        // Квадрат размером 100х100 пикселей в центре экрана
        if (x >= 270 && x < 370 && y >= 190 && y < 290) begin
            r = 3'b111; g = 3'b111; b = 3'b111; // Белый цвет внутри квадрата
        end else begin
            r = 3'b000; g = 3'b000; b = 3'b111; // Синий фон для всего остального экрана
        end
    end
end

// Основной поток симуляции
initial begin
    // Настройки для EDA Playground, чтобы открылся график сигналов (EPWave)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_vga);

    // Сброс системы
    reset = 1;
    #100;
    reset = 0;
    #(1000 * 40); 
    
    $display("Симуляция успешно завершена!");
    $finish;
end

endmodule
