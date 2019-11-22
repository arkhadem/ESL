`include "sys_defs.svh"

module LFSR_TB ();

    reg clock = 1'b0;
    wire [`BIN_LEN-1:0] out_val;

    LFSR UUT (
        .clock(clock),
        .enable(1),
        .init(0),
        .init_val(0),
        .out_val(out_val)
    );


    always @(*)
        #10 clock <= ~clock;

endmodule
