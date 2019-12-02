`include "sys_defs.svh"

module index_counter(
    input clock,
    input reset,
    input enable,

    output reg [(`INPUT_WIDTH_LOG - 1) : 0] width_index,
    output reg [(`INPUT_HEIGHT_LOG - 1) : 0] height_index
);
    always@(posedge clock) begin
        if(reset) begin
            width_index = 0;
            height_index = 0;
        end else if (enable) begin
            if(width_index == `INPUT_WIDTH - 1) begin
                width_index = 0;
                height_index = height_index + 1;
            end else begin
                width_index = width_index + 1;
            end
        end
    end
endmodule
