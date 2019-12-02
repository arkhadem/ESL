`include "sys_defs.svh"

module processing_element(
    input clock,
    input reset,
    input enable,
    input input_val_x,
    input input_val_y,
    input [(`BIN_LEN - 1) : 0] init_val,
    input [(`BIN_LEN - 1) : 0] weight_val,
    output reg [(`BIN_LEN - 1) : 0] output_val
);

    wire weight_x;
    wire mult_x, mult_y;
    wire half_cnt;
    wire half_sc;

    wire output_val_x;
    wire output_val_y;

    wire init_val_x, init_val_y;

    SNG SNG_weight_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .in_val(weight_val),
        .out_val(weight_x)
    );

    ESL_multiplier multiplier_inst(

        .a_x(weight_x),
        .a_y(1'b1),

        .b_x(input_val_x),
        .b_y(input_val_y),

        .o_x(mult_x),
        .o_y(mult_y)
    );

    SNG SNG_half_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .in_val({1'b1, {(`BIN_LEN - 1){1'b0}}}),
        .out_val(half_sc)
    );

    one_counter one_counter_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .count(half_cnt)
    );

    SNG SNG_init_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .in_val(init_val),
        .out_val(init_val_x)
    );
    assign init_val_y = 1;

    ESL_adder adder_inst(
        .half_sc(half_sc),
        .half_cnt(half_cnt),

        .a_x(mult_x),
        .a_y(mult_y),
        .b_x(init_val_x),
        .b_y(init_val_y),

        .o_x(output_val_x),
        .o_y(output_val_y)
    );

    ESL_bioilar_divider P2B_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),

        .a_x(output_val_x),
        .a_y(output_val_y),

        .out_bin(output_val)
    );

endmodule
