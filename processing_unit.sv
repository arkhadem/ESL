`include "sys_defs.svh"

module processing_unit(
    input clock,
    input reset,
    input start,

    output input_req,
    input [(`BIN_LEN - 1) : 0] input_val,
    input input_ready,


    input [(`BIN_LEN - 1) : 0] weight_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0],

    output [(`OUT_BIN_LEN - 1) : 0] output_val,
    output output_valid,

    output done
);

    genvar i, j;
    reg [(`BIN_LEN - 1) : 0] init_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    reg enables [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    reg [(`INPUT_WIDTH_LOG - 1) : 0] width_index;
    reg [(`INPUT_HEIGHT_LOG - 1) : 0] height_index;

    wire PE_reset, PE_enable, PE_init;
    wire index_reset, index_enable;
    wire partial_sum_reset, partial_sum_enable;
    wire SNG_enable;

    wire output_valid_tmp;

    wire sc_count_enable, sc_count_reset;
    wire sc_count_done;


    wire [(`BIN_LEN - 1) : 0] output_val_tmp [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    reg [(`BIN_LEN - 1) : 0] store_vals [(`KERNEL_HEIGHT - 1) : 0];
    wire [(`BIN_LEN - 1) : 0] fetch_vals [(`KERNEL_HEIGHT - 1) : 0];


    controller controller_inst(
        .clock(clock),
        .reset(reset),
        .start(start),
        .input_ready(input_ready),
        .sc_count_done(sc_count_done),

        .width_index(width_index),
        .height_index(height_index),

        .PE_reset(PE_reset),
        .PE_enable(PE_enable),
        .PE_init(PE_init),
        .index_reset(index_reset),
        .index_enable(index_enable),
        .partial_sum_reset(partial_sum_reset),
        .partial_sum_enable(partial_sum_enable),
        .output_valid(output_valid_tmp),
        .input_req(input_req),
        .sc_count_enable(sc_count_enable),
        .sc_count_reset(sc_count_reset),
        .SNG_enable(SNG_enable),
        .done(done)
    );

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
                .init_val(init_vals[i][j]),
                .weight_val(weight_vals[i][j]),
                .output_val(output_val_tmp[i][j])
            );

        end
    end

    always@(*) begin
        for (int i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin
            for (int j = 1; j < `KERNEL_HEIGHT; j = j + 1) begin
                init_vals[i][j] = output_val_tmp[i][j-1];
            end
            for (int j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin
                enables[i][j] = ((i <= height_index) && (j <= width_index) && (width_index + `KERNEL_WIDTH - 1 - j < `INPUT_WIDTH) && (height_index + `KERNEL_HEIGHT - 1 - i < `INPUT_HEIGHT)) ? 1 : 0;
            end
            store_vals[i] = output_val_tmp[i][(`KERNEL_WIDTH - 1)];
            init_vals[i][0] = fetch_vals[i];
        end
    end

    assign output_valid = ((output_valid_tmp == 1) && (width_index >= (`KERNEL_WIDTH - 1)) && (height_index >= (`KERNEL_HEIGHT - 1))) ? 1 : 0;
    assign output_val = output_val_tmp[(`KERNEL_HEIGHT - 1)][(`KERNEL_WIDTH - 1)];

    index_counter index_counter_inst(
        .clock(clock),
        .reset(index_reset|reset),
        .enable(index_enable),

        .width_index(width_index),
        .height_index(height_index)
    );

    partial_result_buffer partial_result_buffer_inst(
        .clock(clock),
        .reset(partial_sum_reset|reset),
        .enable(partial_sum_enable),

        .store_vals(store_vals),

        .width_index(width_index),

        .fetch_vals(fetch_vals)
    );

    sc_counter sc_counter_inst(
        .clock(clock),
        .reset(sc_count_reset|reset),
        .enable(sc_count_enable),

        .sc_count_done(sc_count_done)
    );

endmodule
