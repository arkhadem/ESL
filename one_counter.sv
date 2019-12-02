`include "sys_defs.svh"


module one_counter(
    input clock,
    input reset,
    input enable,

    output reg count
);

    always@(posedge clock) begin
        if(reset) begin
            count = 0;
        end else if(enable) begin
            count = 1 - count;
        end
    end

endmodule
