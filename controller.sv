`include "sys_defs.svh"

module controller(
    input clock,
    input reset,
    input start,
    input input_ready,
    input sc_count_done,

    input [(`INPUT_WIDTH_LOG - 1) : 0] width_index,
    input [(`INPUT_HEIGHT_LOG - 1) : 0] height_index,

    output reg PE_reset,
    output reg PE_enable,
    output reg PE_init,
    output reg index_reset,
    output reg index_enable,
    output reg partial_sum_reset,
    output reg partial_sum_enable,
    output reg output_valid,
    output reg input_req,
    output reg sc_count_enable,
    output reg sc_count_reset,
    output reg SNG_enable,
    output reg ESL_bipolar_divider_enable,
    output reg done
);

    parameter   WAIT_FOR_START = 3'd0,
                RESET_SIGNALS = 3'd1,
                WAIT_FOR_INPUT = 3'd2,
                INIT_SIGNALS = 3'd3,
                WAIT_FOR_ZERO = 3'd4,
                OUTPUT_IS_READY = 3'd5,
                INDEX_INCREMENT = 3'd6,
                DONE_FLAG = 3'd7;

    reg [2:0] state, next_state;

    always@(state) begin
        input_req = 0;
        PE_reset = 0;
        PE_enable = 0;
        PE_init = 0;
        index_reset = 0;
        index_enable = 0;
        partial_sum_reset = 0;
        partial_sum_enable = 0;
        output_valid = 0;
        sc_count_enable = 0;
        sc_count_reset = 0;
        SNG_enable = 0;
        ESL_bipolar_divider_enable = 0;
        done = 0;

        case (state)
            RESET_SIGNALS: begin
                index_reset = 1;
                PE_reset = 1;
                partial_sum_reset = 1;
            end

            WAIT_FOR_INPUT: input_req = 1;

            INIT_SIGNALS: begin
                PE_init = 1;
                sc_count_reset = 1;
            end

            WAIT_FOR_ZERO: begin
                PE_enable = 1;
                SNG_enable = 1;
                sc_count_enable = 1;
                partial_sum_enable = 1;
                ESL_bipolar_divider_enable = 1;
            end

            OUTPUT_IS_READY: begin
                output_valid = 1;
            end

            INDEX_INCREMENT: begin
                index_enable = 1;
            end

            DONE_FLAG: done = 1;

            default: begin
                input_req = 0;
                PE_reset = 0;
                PE_enable = 0;
                PE_init = 0;
                index_reset = 0;
                index_enable = 0;
                partial_sum_reset = 0;
                partial_sum_enable = 0;
                output_valid = 0;
                sc_count_enable = 0;
                sc_count_reset = 0;
                SNG_enable = 0;
                ESL_bipolar_divider_enable = 0;
                done = 0;
            end
        endcase
    end


    always@(*) begin
        next_state = WAIT_FOR_START;
        case (state)
            WAIT_FOR_START:
                if(start)
                    next_state = RESET_SIGNALS;
                else
                    next_state = WAIT_FOR_START;

            RESET_SIGNALS: next_state = WAIT_FOR_INPUT;

            WAIT_FOR_INPUT:
                if(input_ready)
                    next_state = INIT_SIGNALS;
                else
                    next_state = WAIT_FOR_INPUT;

            INIT_SIGNALS: next_state = WAIT_FOR_ZERO;

            WAIT_FOR_ZERO:
                if(sc_count_done)
                    next_state = OUTPUT_IS_READY;
                else
                    next_state = WAIT_FOR_ZERO;

            OUTPUT_IS_READY:
                next_state = INDEX_INCREMENT;

            INDEX_INCREMENT:
                if((width_index == `INPUT_WIDTH - 1) && (height_index == `INPUT_HEIGHT - 1))
                    next_state = DONE_FLAG;
                else
                    next_state = WAIT_FOR_INPUT;

            DONE_FLAG: next_state = WAIT_FOR_START;

            default: next_state = WAIT_FOR_START;
        endcase
    end

    always@(posedge clock) begin
        if(reset) begin
            state = WAIT_FOR_START;
        end else begin
            state = next_state;
        end
    end

endmodule
