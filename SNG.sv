`include "sys_defs.svh"

module SNG (
    input clock,
    input reset,
    input enable,

    input [(`BIN_LEN - 1) : 0] in_val,
    output out_val
);

    wire [(`BIN_LEN - 1) : 0] random_number;

    LFSR UUT (
        .clock(clock),
        .enable(enable),
        .init(reset),
        .init_val(`LFSR_INIT_VAL),
        .out_val(random_number)
    );

    assign out_val = (in_val >= random_number) ? 1 : 0;

endmodule
