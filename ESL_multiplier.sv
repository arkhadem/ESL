`include "sys_defs.svh"

module ESL_multiplier(
    input a_x, a_y, b_x, b_y,

    output o_x, o_y
);

    assign o_x = a_x ~^ b_x;
    assign o_y = a_y ~^ b_y;

endmodule
