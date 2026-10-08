module light (
    input wire clk,
    input wire reset,
    output reg red,
    output reg yellow,
    output reg green
);

localparam RED    = 2'b00;
localparam GREEN  = 2'b01;
localparam YELLOW = 2'b10;

reg [1:0] state;
reg [3:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= RED;
        counter <= 0;
    end else begin
        counter <= counter + 1;
        case (state)
            RED:    if (counter == 9)  begin state <= GREEN;  counter <= 0; end
            GREEN:  if (counter == 9)  begin state <= YELLOW; counter <= 0; end
            YELLOW: if (counter == 4)  begin state <= RED;    counter <= 0; end
        endcase
    end
end

always @(*) begin
    red    = (state == RED);
    green  = (state == GREEN);
    yellow = (state == YELLOW);
end

endmodule
