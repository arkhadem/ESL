`include "sys_defs.svh"

module partial_result_buffer(
    input clock,
    input reset,
    input enable,

    input [(`BIN_LEN - 1) : 0] store_vals [(`KERNEL_HEIGHT - 1) : 0],

    input [(`INPUT_WIDTH_LOG - 1) : 0] width_index,

    output reg [(`BIN_LEN - 1) : 0] fetch_vals [(`KERNEL_HEIGHT - 1) : 0]
);

    reg [(`BIN_LEN - 1) : 0] stored_partial_sums [(`KERNEL_HEIGHT - 2) : 0][(`INPUT_WIDTH - 1) : 0];

    always@(posedge clock) begin
        if(reset) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                for(int j = 0; j < `INPUT_WIDTH; j++) begin
                    stored_partial_sums[i][j] = 0;
                end
            end
        end else if(enable) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                stored_partial_sums[i][width_index - (`KERNEL_WIDTH - 1)] = store_vals[i];
            end
        end
    end

    always@(*) begin
        for (int i = 1; i < `KERNEL_HEIGHT; i = i + 1) begin
            fetch_vals[i] = stored_partial_sums[i - 1][width_index];
        end
        fetch_vals[0] = 0;
    end

endmodule
