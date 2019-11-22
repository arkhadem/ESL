`include "sys_defs.svh"

module P2B(
    input clock,
    input reset,
    input enable,

    input in_val,

    output reg [(`BIN_LEN - 1) : 0] out_val
);

    reg [(`BIN_LEN - 1) : 0] n_out_val;
    reg [(`BIN_LEN - 1) : 0] modulus_m;
    wire storage_ld;

    always@(posedge clock) begin
        if(reset || storage_ld) begin
            n_out_val = 0;
        end else if(enable && in_val) begin
            n_out_val = n_out_val + 1;
        end
    end

    always@(clock) begin
        if(reset) begin
            modulus_m = 0;
        end else if(enable) begin
            if(storage_ld) begin
                modulus_m = 0;
            end else begin
                modulus_m = modulus_m + 1;
            end
        end
    end

    assign storage_ld = (modulus_m == `LFSR_INIT_VAL - 1) ? 1 : 0;

    always@(posedge clock) begin
        if(reset) begin
            out_val = 0;
        end else if (enable && storage_ld) begin
            out_val = n_out_val;
        end
    end

endmodule
