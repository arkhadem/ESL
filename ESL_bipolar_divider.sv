`include "sys_defs.svh"

module ESL_bioilar_divider(
    input clock,
    input reset,
    input enable,

    input a_x, a_y,

    output reg [(`BIN_LEN - 1) : 0] out_bin
);

    wire up_or_down;
    wire up_down_count_enable;
    reg est_max;
    reg est_min;
    wire SC_estimation;
    reg [(`BIN_LEN - 1) : 0] estimation_tmp;
    wire [(`BIN_LEN - 1) : 0] a_y_bin;

    assign est_max = (estimation_tmp == {`BIN_LEN{1'b1}}) ? 1 : 0;
    assign est_min = (estimation_tmp == 0) ? 1 : 0;
    assign up_or_down = (~est_max) & (a_x | est_min);
    assign up_down_count_enable = a_x ^ (a_y ~^ SC_estimation);
    assign out_bin = (a_y_bin >= {1'b1, {(`BIN_LEN-1){1'b0}}}) ? estimation_tmp : ~estimation_tmp;

    P2B P2B_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .in_val(a_y),

        .out_val(a_y_bin)
    );


    always@(posedge clock) begin
        if(reset) begin
            estimation_tmp = 0;
        end else if (enable && up_down_count_enable) begin
            if(up_or_down) begin
                estimation_tmp = estimation_tmp + 1;
            end else begin
                estimation_tmp = estimation_tmp - 1;
            end
        end
    end

    SNG SNG_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .in_val(estimation_tmp),
        .out_val(SC_estimation)
    );


endmodule
