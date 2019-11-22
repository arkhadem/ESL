`include "sys_defs.svh"

module LFSR (
    input clock,
    input enable,

    input init,
    input [`BIN_LEN-1:0] init_val,

    output [`BIN_LEN-1:0] out_val
);

    reg [`BIN_LEN:1] LFSR_reg = 0;
    reg              XNOR_reg;


    always @(posedge clock)
    begin
    if (enable == 1'b1)begin
        if (init == 1'b1)
            LFSR_reg <= init_val;
        else
            LFSR_reg <= {LFSR_reg[`BIN_LEN-1:1], XNOR_reg};
        end
    end

    always @(*) begin
        case (`BIN_LEN)
            3: begin
                XNOR_reg = LFSR_reg[3] ^~ LFSR_reg[2];
            end
            4: begin
                XNOR_reg = LFSR_reg[4] ^~ LFSR_reg[3];
            end
            5: begin
                XNOR_reg = LFSR_reg[5] ^~ LFSR_reg[3];
            end
            6: begin
                XNOR_reg = LFSR_reg[6] ^~ LFSR_reg[5];
            end
            7: begin
                XNOR_reg = LFSR_reg[7] ^~ LFSR_reg[6];
            end
            8: begin
                XNOR_reg = LFSR_reg[8] ^~ LFSR_reg[6] ^~ LFSR_reg[5] ^~ LFSR_reg[4];
            end
            9: begin
                XNOR_reg = LFSR_reg[9] ^~ LFSR_reg[5];
            end
            10: begin
                XNOR_reg = LFSR_reg[10] ^~ LFSR_reg[7];
            end
            11: begin
                XNOR_reg = LFSR_reg[11] ^~ LFSR_reg[9];
            end
            12: begin
                XNOR_reg = LFSR_reg[12] ^~ LFSR_reg[6] ^~ LFSR_reg[4] ^~ LFSR_reg[1];
            end
            13: begin
                XNOR_reg = LFSR_reg[13] ^~ LFSR_reg[4] ^~ LFSR_reg[3] ^~ LFSR_reg[1];
            end
            14: begin
                XNOR_reg = LFSR_reg[14] ^~ LFSR_reg[5] ^~ LFSR_reg[3] ^~ LFSR_reg[1];
            end
            15: begin
                XNOR_reg = LFSR_reg[15] ^~ LFSR_reg[14];
            end
            16: begin
                XNOR_reg = LFSR_reg[16] ^~ LFSR_reg[15] ^~ LFSR_reg[13] ^~ LFSR_reg[4];
            end
            17: begin
                XNOR_reg = LFSR_reg[17] ^~ LFSR_reg[14];
            end
            18: begin
                XNOR_reg = LFSR_reg[18] ^~ LFSR_reg[11];
            end
            19: begin
                XNOR_reg = LFSR_reg[19] ^~ LFSR_reg[6] ^~ LFSR_reg[2] ^~ LFSR_reg[1];
            end
            20: begin
                XNOR_reg = LFSR_reg[20] ^~ LFSR_reg[17];
            end
            21: begin
                XNOR_reg = LFSR_reg[21] ^~ LFSR_reg[19];
            end
            22: begin
                XNOR_reg = LFSR_reg[22] ^~ LFSR_reg[21];
            end
            23: begin
                XNOR_reg = LFSR_reg[23] ^~ LFSR_reg[18];
            end
            24: begin
                XNOR_reg = LFSR_reg[24] ^~ LFSR_reg[23] ^~ LFSR_reg[22] ^~ LFSR_reg[17];
            end
            25: begin
                XNOR_reg = LFSR_reg[25] ^~ LFSR_reg[22];
            end
            26: begin
                XNOR_reg = LFSR_reg[26] ^~ LFSR_reg[6] ^~ LFSR_reg[2] ^~ LFSR_reg[1];
            end
            27: begin
                XNOR_reg = LFSR_reg[27] ^~ LFSR_reg[5] ^~ LFSR_reg[2] ^~ LFSR_reg[1];
            end
            28: begin
                XNOR_reg = LFSR_reg[28] ^~ LFSR_reg[25];
            end
            29: begin
                XNOR_reg = LFSR_reg[29] ^~ LFSR_reg[27];
            end
            30: begin
                XNOR_reg = LFSR_reg[30] ^~ LFSR_reg[6] ^~ LFSR_reg[4] ^~ LFSR_reg[1];
            end
            31: begin
                XNOR_reg = LFSR_reg[31] ^~ LFSR_reg[28];
            end
            32: begin
                XNOR_reg = LFSR_reg[32] ^~ LFSR_reg[22] ^~ LFSR_reg[2] ^~ LFSR_reg[1];
            end

        endcase
    end

    assign out_val = LFSR_reg[`BIN_LEN:1];

endmodule
