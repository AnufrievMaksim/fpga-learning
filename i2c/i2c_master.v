module i2c_master (
    input wire clk,               // Тактовый сигнал (10 МГц)
    input wire reset,             // Асинхронный сброс
    input wire start,             // Сигнал инициализации передачи
    input wire [6:0] addr,        // Входной адрес ведомого устройства
    input wire [7:0] data,        // Входной байт данных для отправки
    output reg sda,               // Выходной сигнал линии данных шины I2C
    output reg scl,               // Выходной сигнал тактовой линии шины I2C
    output reg done,              // Флаг успешного завершения передачи
    output reg busy               // Флаг занятости модуля
);

localparam CLK_DIV  = 4;          // Уменьшено до 4 для быстрой симуляции
localparam IDLE     = 3'b000;
localparam START    = 3'b001;
localparam ADDR     = 3'b010;
localparam ACK1     = 3'b011;
localparam DATA     = 3'b100;
localparam ACK2     = 3'b101;
localparam STOP     = 3'b110;

// Внутренние управляющие регистры
reg [2:0] state;                  // Регистр текущего состояния 
reg [7:0] clk_cnt;                // Счетчик делителя частоты
reg [3:0] bit_idx;                // Счетчик индекса передаваемого бита
reg [8:0] shift_reg;              // Сдвиговый регистр данных

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state    <= IDLE;
        sda      <= 1'b1;
        scl      <= 1'b1;
        done     <= 1'b0;
        busy     <= 1'b0;
        clk_cnt  <= 0;
        bit_idx  <= 0;
        shift_reg<= 0;
    end else begin
        done <= 1'b0; 
        
        case (state)
            IDLE: begin
                sda <= 1'b1;
                scl <= 1'b1;
                busy <= 1'b0;
                
                if (start) begin
                    state     <= START;
                    shift_reg <= {addr, 1'b0};  
                    clk_cnt   <= 0;
                    busy      <= 1'b1;
                end
            end
            
            START: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    sda <= 1'b0;  
                    state <= ADDR;
                    bit_idx <= 0;
                end else clk_cnt <= clk_cnt + 1;
            end
            
            ADDR: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    scl <= ~scl;  
                    
                    if (scl == 1'b0) begin
                        sda <= shift_reg[7 - bit_idx]; 
                    end else begin
                        if (bit_idx == 7) begin
                            state <= ACK1;
                            bit_idx <= 0; 
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end else clk_cnt <= clk_cnt + 1;
            end
            
            ACK1: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    scl <= ~scl;
                    
                    if (scl == 1'b1 && bit_idx == 0) begin
                        sda <= 1'b0;  
                        bit_idx <= 1;
                    end else if (bit_idx == 1 && scl == 1'b0) begin
                        state     <= DATA;
                        shift_reg <= data; 
                        bit_idx   <= 0;
                    end
                end else clk_cnt <= clk_cnt + 1;
            end
            
            DATA: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    scl <= ~scl;
                    
                    if (scl == 1'b0) begin
                        sda <= shift_reg[7 - bit_idx]; 
                    end else begin
                        if (bit_idx == 7) begin
                            state <= ACK2;
                            bit_idx <= 0; 
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end else clk_cnt <= clk_cnt + 1;
            end
            
            ACK2: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    scl <= ~scl;
                    
                    if (scl == 1'b1 && bit_idx == 0) begin
                        sda <= 1'b0;  
                        bit_idx <= 1;
                    end else if (bit_idx == 1 && scl == 1'b0) begin
                        state <= STOP;
                    end
                end else clk_cnt <= clk_cnt + 1;
            end
            
            STOP: begin
                if (clk_cnt == CLK_DIV - 1) begin
                    clk_cnt <= 0;
                    scl <= 1'b1;
                    sda <= 1'b1;  
                    state <= IDLE;
                    done  <= 1'b1; 
                    busy  <= 1'b0;
                end else clk_cnt <= clk_cnt + 1;
            end
        endcase
    end
end

endmodule
