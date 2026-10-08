module uart_tx (
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);

parameter CLK_FREQ = 50000000;
parameter BAUD     = 9600;
localparam BIT_TICKS = CLK_FREQ / BAUD;

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [15:0] tick_cnt;
reg [2:0] bit_idx;
reg [7:0] data_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state    <= IDLE;
        tx       <= 1'b1;
        tx_busy  <= 1'b0;
        tick_cnt <= 0;
        bit_idx  <= 0;
        data_reg <= 0;
    end else begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                if (tx_start) begin
                    state    <= START;
                    data_reg <= tx_data;
                    tick_cnt <= 0;
                    tx_busy  <= 1'b1;
                end else begin
                    tx_busy <= 1'b0;
                end
            end
            START: begin
                tx <= 1'b0;
                if (tick_cnt == BIT_TICKS - 1) begin
                    tick_cnt <= 0;
                    state    <= DATA;
                    bit_idx  <= 0;
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
            DATA: begin
                tx <= data_reg[bit_idx];
                if (tick_cnt == BIT_TICKS - 1) begin
                    tick_cnt <= 0;
                    if (bit_idx == 7) state <= STOP;
                    else bit_idx <= bit_idx + 1;
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
            STOP: begin
                tx <= 1'b1;
                if (tick_cnt == BIT_TICKS - 1) begin
                    tick_cnt <= 0;
                    state    <= IDLE;
                    tx_busy  <= 1'b0;
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
        endcase
    end
end

endmodule
