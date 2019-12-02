`include "sys_defs.svh"

module sc_counter(
    input clock,
    input reset,
    input enable,

    output reg [(`SC_LEN_LOG - 1) : 0] sc_count,

    wire sc_count_done
);

    always@(posedge clock) begin
        if(reset) begin
            sc_count = 0;
        end else if(enable) begin
            sc_count = sc_count + 1;
        end
    end

    assign sc_count_done = (sc_count == `SC_LEN-1) ? 1 : 0;

endmodule
