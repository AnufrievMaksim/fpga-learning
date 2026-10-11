module spi_master (
    input wire clk,               
    input wire reset,             
    input wire start,             
    input wire [7:0] tx_data,     
    output reg sck,               
    output reg mosi,              
    input wire miso,              
    output reg cs,                
    output reg [7:0] rx_data,     
    output reg transfer_done,     
    output reg busy               
);

// Параметры временных интервалов и состояний
localparam SCK_HALF_PERIOD = 4;  
localparam IDLE     = 2'b00;
localparam TRANSFER = 2'b01;
localparam FINISH   = 2'b10;

// Внутренние регистры автомата
reg [1:0] state;                  
reg [3:0] sck_counter;            
reg [2:0] bit_position;           
reg [7:0] tx_register;            
reg [7:0] rx_register;            

// Логика управления конечным автоматом SPI
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state         <= IDLE;
        sck           <= 1'b0;
        mosi          <= 1'b0;
        cs            <= 1'b1;
        rx_data       <= 8'h00;
        transfer_done <= 1'b0;
        busy          <= 1'b0;
        sck_counter   <= 0;
        bit_position  <= 0;
        tx_register   <= 0;
        rx_register   <= 0;
    end else begin
        transfer_done <= 1'b0;  
        
        case (state)
            IDLE: begin
                cs   <= 1'b1;
                sck  <= 1'b0;
                busy <= 1'b0;
                
                if (start) begin
                    state        <= TRANSFER;
                    tx_register  <= tx_data;
                    bit_position <= 0;
                    sck_counter  <= 0;
                    cs           <= 1'b0;
                    busy         <= 1'b1;
                end
            end
            
            TRANSFER: begin
                if (sck_counter == SCK_HALF_PERIOD - 1) begin
                    sck_counter <= 0;
                    
                    if (sck == 1'b0) begin
                        // Передний фронт: обновление линии MOSI
                        sck  <= 1'b1;
                        mosi <= tx_register[7 - bit_position];
                    end else begin
                        // Задний фронт: фиксация данных с линии MISO
                        sck <= 1'b0;
                        rx_register[7 - bit_position] <= miso;
                        
                        if (bit_position == 7) begin
                            state   <= FINISH;
                            rx_data <= rx_register;
                        end else begin
                            bit_position <= bit_position + 1;
                        end
                    end
                end else begin
                    sck_counter <= sck_counter + 1;
                end
            end
            
            FINISH: begin
                cs            <= 1'b1;
                transfer_done <= 1'b1;
                busy          <= 1'b0;
                state         <= IDLE;
            end
        endcase
    end
end

endmodule
