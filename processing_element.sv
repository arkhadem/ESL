`include "sys_defs.svh"

module processing_element(
    input clock,
    input reset,
    input enable,
    input input_val_x,
    input input_val_y,
    input init_val_x,
    input init_val_y,
    input [(`BIN_LEN - 1) : 0] weight_val,
    output output_val_x,
    output output_val_y
);

    wire weight_x;
    wire mult_x, mult_y;

    SNG SNG_inst(
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

    ESL_adder adder_inst(
        .a_x(mult_x),
        .a_y(mult_y),

        .b_x(init_val_x),
        .b_y(init_val_y),

        .o_x(output_val_x),
        .o_y(output_val_y)
    );

endmodule
