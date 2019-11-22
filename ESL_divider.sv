`include "sys_defs.svh"

module ESL_divider(
    input clock,
    input reset,
    input enable,

    input half,

    input a_x, a_y, b_x, b_y,

    output o_x, o_y
);

    assign o_x = (half == 1) ? a_x ~^ b_y : a_y ~^ b_x;
    assign o_y = a_y ~^ b_y ~^ half;

endmodule
