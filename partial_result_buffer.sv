`include "sys_defs.svh"

module partial_result_buffer(
    input clock,
    input reset,
    input enable,

    input [(`KERNEL_HEIGHT - 1) : 0] store_vals_x,
    input [(`KERNEL_HEIGHT - 1) : 0] store_vals_y,

    input [(`INPUT_WIDTH_LOG - 1) : 0] width_index,
    input [(`SC_LEN_LOG - 1) : 0] sc_count,

    output reg [(`KERNEL_HEIGHT - 1) : 0] fetch_vals_x,
    output reg [(`KERNEL_HEIGHT - 1) : 0] fetch_vals_y
);

    reg [(`SC_LEN - 1) : 0] stored_partial_sums_x [(`KERNEL_HEIGHT - 2) : 0][(`INPUT_WIDTH - 1) : 0];
    reg [(`SC_LEN - 1) : 0] stored_partial_sums_y [(`KERNEL_HEIGHT - 2) : 0][(`INPUT_WIDTH - 1) : 0];

    always@(posedge clock) begin
        if(reset) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                for(int j = 0; j < `INPUT_WIDTH; j++) begin
                    stored_partial_sums_x[i][j] = 0;
                    stored_partial_sums_y[i][j] = 0;
                end
            end
        end else if(enable) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                stored_partial_sums_x[i][width_index - (`KERNEL_WIDTH - 1)][sc_count] = store_vals_x[i];
                stored_partial_sums_y[i][width_index - (`KERNEL_WIDTH - 1)][sc_count] = store_vals_y[i];
            end
        end
    end

    always@(*) begin
        for (int i = 1; i < `KERNEL_HEIGHT; i = i + 1) begin
            fetch_vals_x[i] = stored_partial_sums_x[i - 1][width_index][sc_count];
            fetch_vals_y[i] = stored_partial_sums_y[i - 1][width_index][sc_count];
        end
        fetch_vals_x[0] = 0;
        fetch_vals_y[0] = 1;
    end

endmodule
