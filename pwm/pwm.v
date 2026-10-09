`timescale 1ns / 1ps

module pwm (
    input wire clk,           // тактовый сигнал
    input wire reset,         // асинхронный сброс
    input wire [7:0] duty,    // скважность (задается числом от 0 до 255)
    output reg pwm_out        // выходной ШИМ-сигнал
);

reg [7:0] counter; // 8-битный внутренний счетчик (считает от 0 до 255)

// Логика работы счетчика и формирования импульсов
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 8'd0;
        pwm_out <= 1'b0;
    end else begin
        counter <= counter + 1; // Счетчик непрерывно инкрементируется по кругу
        
        // Сравнение счетчика со скважностью
        if (counter < duty)
            pwm_out <= 1'b1;    // Пока счетчик меньше duty — на выходе единица
        else
            pwm_out <= 1'b0;    // Как только догнал или перерос duty — на выходе ноль
    end
end

endmodule
