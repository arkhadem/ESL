`include "sys_defs.svh"


module ESL_adder(
    input half_sc,
    input half_cnt,

    input a_x, a_y, b_x, b_y,

    output o_x, o_y
);

    assign o_x = (half_cnt == 1) ? a_x ~^ b_y : a_y ~^ b_x;
    assign o_y = a_y ~^ b_y ~^ half_sc;



endmodule
