module vga_controller (
    input wire clk,        // 25 МГц
    input wire reset,
    output reg hsync,      // горизонтальная синхронизация
    output reg vsync,      // вертикальная синхронизация
    output reg [9:0] x,    // текущий пиксель по X (0..639)
    output reg [9:0] y,    // текущая строка по Y (0..479)
    output reg video_on    // активная область (видимая)
);

// Параметры VGA 640x480 @ 60 Гц
localparam H_VISIBLE  = 640;
localparam H_FRONT    = 16;
localparam H_SYNC     = 96;
localparam H_BACK     = 48;
localparam H_TOTAL    = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;  // 800

localparam V_VISIBLE  = 480;
localparam V_FRONT    = 10;
localparam V_SYNC     = 2;
localparam V_BACK     = 33;
localparam V_TOTAL    = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;  // 525

reg [9:0] h_cnt;
reg [9:0] v_cnt;

// Горизонтальный счётчик
always @(posedge clk or posedge reset) begin
    if (reset) h_cnt <= 0;
    else if (h_cnt == H_TOTAL - 1) h_cnt <= 0;
    else h_cnt <= h_cnt + 1;
end

// Вертикальный счётчик
always @(posedge clk or posedge reset) begin
    if (reset) v_cnt <= 0;
    else if (h_cnt == H_TOTAL - 1) begin
        if (v_cnt == V_TOTAL - 1) v_cnt <= 0;
        else v_cnt <= v_cnt + 1;
    end
end

// HSYNC
always @(*) begin
    if (h_cnt < H_VISIBLE + H_FRONT)
        hsync = 1'b1;
    else if (h_cnt < H_VISIBLE + H_FRONT + H_SYNC)
        hsync = 1'b0;
    else
        hsync = 1'b1;
end

// VSYNC
always @(*) begin
    if (v_cnt < V_VISIBLE + V_FRONT)
        vsync = 1'b1;
    else if (v_cnt < V_VISIBLE + V_FRONT + V_SYNC)
        vsync = 1'b0;
    else
        vsync = 1'b1;
end

// Видимая область
always @(*) begin
    video_on = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);
end

always @(*) begin
    if (video_on) begin
        x = h_cnt;
        y = v_cnt;
    end else begin
        x = 10'd0;
        y = 10'd0;
    end
end

endmodule

