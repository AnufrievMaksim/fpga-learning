`timescale 1ns / 1ps

module uart_rx (
    input wire clk,           // тактовый сигнал (50 МГц)
    input wire reset,         // асинхронный сброс
    input wire rx,            // физическая линия связи RX
    output reg [7:0] rx_data, // выходная шина принятого байта данных
    output reg rx_done,       // импульс готовности (длительностью в 1 такт)
    output reg rx_busy        // флаг занятости модуля приемом
);

// Параметры скорости передачи
parameter CLK_FREQ = 50000000;
parameter BAUD     = 9600;
localparam BIT_TICKS = CLK_FREQ / BAUD;       // Количество тактов чипа на один бит UART
localparam HALF_TICKS = BIT_TICKS / 2;        // Тактов до середины бита (для помехоустойчивости)

// Состояния конечного автомата (FSM Moore)
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;       // Регистр текущего состояния
reg [15:0] tick_cnt;   // Счетчик тактов для отсчета времени
reg [2:0] bit_idx;     // Индекс принимаемого бита (от 0 до 7)
reg [7:0] data_reg;    // Внутренний сдвиговый регистр для побитовой сборки байта

// Логика работы автомата
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state    <= IDLE;
        tick_cnt <= 0;
        bit_idx  <= 0;
        data_reg <= 0;
        rx_data  <= 0;
        rx_done  <= 0;
        rx_busy  <= 0;
    end else begin
        rx_done <= 0;  // Автоматический сброс флага на следующем такте (генерация строба)
        
        case (state)
            IDLE: begin
                rx_busy <= 0;
                if (rx == 1'b0) begin  // Фиксация спада линии в 0 (потенциальный Старт-бит)
                    state    <= START;
                    tick_cnt <= 0;
                    rx_busy  <= 1;
                end
            end
            
            START: begin
                // Ждём половину бита, чтобы попасть точно в его центр
                if (tick_cnt == HALF_TICKS - 1) begin
                    if (rx == 1'b0) begin  // Контрольная проверка: если все еще 0 — старт реальный
                        tick_cnt <= 0;
                        state    <= DATA;
                        bit_idx  <= 0;
                    end else begin
                        state <= IDLE;  // Если на линии оказалась 1 — это была ложная помеха
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
            
            DATA: begin
                // Отсчитываем полные биты, делая замеры строго в центре каждого информационного бита
                if (tick_cnt == BIT_TICKS - 1) begin
                    tick_cnt <= 0;
                    data_reg[bit_idx] <= rx;  // Записываем бит с провода в нужную ячейку "сейфа"
                    
                    if (bit_idx == 7) begin
                        state <= STOP;
                    end else begin
                        bit_idx <= bit_idx + 1; // Сдвигаем индекс к следующему проводу шины
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
            
            STOP: begin
                // Ожидаем завершения Стоп-бита (полная длительность бита)
                if (tick_cnt == BIT_TICKS - 1) begin
                    tick_cnt <= 0;
                    state    <= IDLE;
                    rx_data  <= data_reg; // Мгновенно выталкиваем весь готовый массив данных на выход
                    rx_done  <= 1;        // Выдаем импульс готовности для внешних модулей
                    rx_busy  <= 0;
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
        endcase
    end
end

endmodule
