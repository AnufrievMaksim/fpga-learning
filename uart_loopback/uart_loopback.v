`timescale 1ns / 1ps

// ===================================================
// ЧЕРТЕЖ №1: UART TX (Передатчик)
// ===================================================
module uart_tx (
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD     = 5000000;  // Частота ускорена до 5 МГц для быстрой симуляции
    localparam BIT_TICKS = CLK_FREQ / BAUD;
    
    localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
    
    reg [1:0] state;
    reg [15:0] tick_cnt;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0;
            tick_cnt <= 0; bit_idx <= 0; data_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        state <= START; data_reg <= tx_data;
                        tick_cnt <= 0; tx_busy <= 1'b1;
                    end else tx_busy <= 1'b0;
                end
                START: begin
                    tx <= 1'b0;
                    if (tick_cnt == BIT_TICKS - 1) begin
                        tick_cnt <= 0; state <= DATA; bit_idx <= 0;
                    end else tick_cnt <= tick_cnt + 1;
                end
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (tick_cnt == BIT_TICKS - 1) begin
                        tick_cnt <= 0;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else tick_cnt <= tick_cnt + 1;
                end
                STOP: begin
                    tx <= 1'b1;
                    if (tick_cnt == BIT_TICKS - 1) begin
                        tick_cnt <= 0; state <= IDLE; tx_busy <= 1'b0;
                    end else tick_cnt <= tick_cnt + 1;
                end
            endcase
        end
    end
endmodule

// ===================================================
// ЧЕРТЕЖ №2: UART RX (Приемник)
// ===================================================
module uart_rx (
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg rx_busy
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD     = 5000000;
    localparam BIT_TICKS  = CLK_FREQ / BAUD;
    localparam HALF_TICKS = BIT_TICKS / 2;
    
    localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
    
    reg [1:0] state;
    reg [15:0] tick_cnt;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; tick_cnt <= 0; bit_idx <= 0;
            data_reg <= 0; rx_data <= 0; rx_done <= 0; rx_busy <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: begin
                    rx_busy <= 0;
                    if (rx == 1'b0) begin
                        state <= START; tick_cnt <= 0; rx_busy <= 1;
                    end
                end
                START: begin
                    if (tick_cnt == HALF_TICKS - 1) begin
                        if (rx == 1'b0) begin
                            tick_cnt <= 0; state <= DATA; bit_idx <= 0;
                        end else state <= IDLE;
                    end else tick_cnt <= tick_cnt + 1;
                end
                DATA: begin
                    if (tick_cnt == BIT_TICKS - 1) begin
                        tick_cnt <= 0;
                        data_reg[bit_idx] <= rx;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else tick_cnt <= tick_cnt + 1;
                end
                STOP: begin
                    if (tick_cnt == BIT_TICKS - 1) begin
                        tick_cnt <= 0; state <= IDLE;
                        rx_data <= data_reg; rx_done <= 1; rx_busy <= 0;
                    end else tick_cnt <= tick_cnt + 1;
                end
            endcase
        end
    end
endmodule

// ===================================================
// ГЛАВНАЯ ПЛАТА: Сборка Loopback с новыми именами
// ===================================================
module uart_loopback (
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    output wire [7:0] rx_data,
    output wire rx_done,
    output wire tx_busy,
    output wire rx_busy
);
    wire tx_line;  // Соединительная кремниевая дорожка внутри чипа
    
    // Создание экземпляра передатчика my_transmitter
    uart_tx my_transmitter (
        .clk(clk), .reset(reset),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx_line), .tx_busy(tx_busy)
    );
    
    // Создание экземпляра приемника my_receiver
    uart_rx my_receiver (
        .clk(clk), .reset(reset),
        .rx(tx_line),  
        .rx_data(rx_data), .rx_done(rx_done), .rx_busy(rx_busy)
    );
endmodule


