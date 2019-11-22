`include "sys_defs.svh"

module processing_unit(
    input clock,
    input reset,
    input start,

    output reg input_req,
    input [(`BIN_LEN - 1) : 0] input_val,
    input input_ready,


    input [(`BIN_LEN - 1) : 0] weight_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0],

    output [(`OUT_BIN_LEN - 1) : 0] output_val,
    output output_valid,

    output reg done
);

    genvar i, j;
    reg init_vals_x [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];
    reg init_vals_y [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];
    wire zero_select;

    reg enables [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    reg [(`INPUT_WIDTH_LOG - 1) : 0] width_index;
    reg [(`INPUT_HEIGHT_LOG - 1) : 0] height_index;

    reg [(`SC_LEN - 1) : 0] stored_partial_sums_x [(`KERNEL_HEIGHT - 2) : 0][(`INPUT_WIDTH - 1) : 0];
    reg [(`SC_LEN - 1) : 0] stored_partial_sums_y [(`KERNEL_HEIGHT - 2) : 0][(`INPUT_WIDTH - 1) : 0];

    reg PE_reset, PE_enable, PE_init;
    reg index_reset, index_enable;
    reg partial_sum_reset, partial_sum_enable;
    reg SNG_enable;

    reg output_valid_tmp;

    logic sc_count_enable, sc_count_reset;
    reg [(`SC_LEN_LOG - 1) : 0] sc_count;

    reg ESL_bipolar_divider_enable;


    reg [(`SC_LEN - 1) : 0] output_vals_x [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];
    reg [(`SC_LEN - 1) : 0] output_vals_y [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    wire [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0] output_val_x, output_val_y;

    parameter   WAIT_FOR_START = 3'd0,
                RESET_SIGNALS = 3'd1,
                WAIT_FOR_INPUT = 3'd2,
                INIT_SIGNALS = 3'd3,
                WAIT_FOR_ZERO = 3'd4,
                OUTPUT_IS_READY = 3'd5,
                INDEX_INCREMENT = 3'd6,
                DONE_FLAG = 3'd7;

    reg [2:0] state, next_state;

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
                if(sc_count == `SC_LEN-1)
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

    always@(state) begin
        input_req = 0;
        PE_reset = 0;
        PE_enable = 0;
        PE_init = 0;
        index_reset = 0;
        index_enable = 0;
        partial_sum_reset = 0;
        partial_sum_enable = 0;
        output_valid_tmp = 0;
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
                output_valid_tmp = 1;
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
                output_valid_tmp = 0;
                sc_count_enable = 0;
                sc_count_reset = 0;
                SNG_enable = 0;
                ESL_bipolar_divider_enable = 0;
                done = 0;
            end
        endcase
    end

    always@(posedge clock) begin
        if(reset) begin
            state = WAIT_FOR_START;
        end else begin
            state = next_state;
        end
    end

    SNG SNG_inst(
        .clock(clock),
        .reset(reset),
        .enable(SNG_enable),

        .in_val(input_val),
        .out_val(input_x)
    );

    for (i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin : PE_row
        for (j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin : PE_column
            processing_element PEs(
                .clock(clock),
                .reset(PE_reset|reset),
                .enable(enables[i][j] && PE_enable),
                .input_val_x(input_x),
                .input_val_y(1'b1),
                .init_val_x(init_vals_x[i][j]),
                .init_val_y(init_vals_y[i][j]),
                .weight_val(weight_vals[i][j]),
                .output_val_x(output_val_x[i][j]),
                .output_val_y(output_val_y[i][j])
            );

        end
    end

    always@(*) begin
        for (int i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin
            for (int j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin
                output_vals_x[i][j][sc_count] = output_val_x[i][j];
                output_vals_y[i][j][sc_count] = output_val_y[i][j];
            end
        end
    end

    always@(*) begin
        for (int i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin
            for (int j = 1; j < `KERNEL_HEIGHT; j = j + 1) begin
                init_vals_x[i][j] = output_vals_x[i][j-1][sc_count];
                init_vals_y[i][j] = output_vals_y[i][j-1][sc_count];
            end
            for (int j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin
                enables[i][j] = ((i <= height_index) && (j <= width_index) && (width_index + `KERNEL_WIDTH - 1 - j < `INPUT_WIDTH) && (height_index + `KERNEL_HEIGHT - 1 - i < `INPUT_HEIGHT)) ? 1 : 0;
            end
        end
        for (int i = 1; i < `KERNEL_HEIGHT; i = i + 1) begin
            init_vals_x[i][0] = stored_partial_sums_x[i - 1][width_index][sc_count];
            init_vals_y[i][0] = stored_partial_sums_y[i - 1][width_index][sc_count];
        end
        init_vals_x[0][0] = 0;
        init_vals_y[0][0] = 0;
    end

    assign output_valid = ((output_valid_tmp == 1) && (width_index >= (`KERNEL_WIDTH - 1)) && (height_index >= (`KERNEL_HEIGHT - 1))) ? 1 : 0;

    ESL_bioilar_divider ESL_bioilar_divider_inst(
        .clock(clock),
        .reset(reset),
        .enable(ESL_bipolar_divider_enable),

        .a_x(output_vals_x[(`KERNEL_HEIGHT - 1)][(`KERNEL_WIDTH - 1)][sc_count]),
        .a_y(output_vals_y[(`KERNEL_HEIGHT - 1)][(`KERNEL_WIDTH - 1)][sc_count]),

        .out_bin(output_val)
    );

    always@(posedge clock) begin
        if(index_reset) begin
            width_index = 0;
            height_index = 0;
        end else if (index_enable) begin
            if(width_index == `INPUT_WIDTH - 1) begin
                width_index = 0;
                height_index = height_index + 1;
            end else begin
                width_index = width_index + 1;
            end
        end
    end

    always@(posedge clock) begin
        if(partial_sum_reset) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                for(int j = 0; j < `INPUT_WIDTH; j++) begin
                    stored_partial_sums_x[i][j] = 0;
                    stored_partial_sums_y[i][j] = 0;
                end
            end
        end else if(partial_sum_enable) begin
            for(int i = 0; i < `KERNEL_HEIGHT - 1; i++) begin
                stored_partial_sums_x[i][width_index - (`KERNEL_WIDTH - 1)][sc_count] = output_vals_x[i][(`KERNEL_WIDTH - 1)][sc_count];
                stored_partial_sums_y[i][width_index - (`KERNEL_WIDTH - 1)][sc_count] = output_vals_y[i][(`KERNEL_WIDTH - 1)][sc_count];
            end
        end
    end

    always@(posedge clock) begin
        if(sc_count_reset) begin
            sc_count = 0;
        end else if(sc_count_enable) begin
            sc_count = sc_count + 1;
        end
    end

endmodule
