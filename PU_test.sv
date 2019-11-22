`include "sys_defs.svh"

module PU_test();

    reg clock;
    reg reset;
    reg start;

    wire input_req;
    reg [(`BIN_LEN - 1) : 0] input_val;
    reg input_ready;


    reg [(`BIN_LEN - 1) : 0] weight_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    wire [(`OUT_BIN_LEN - 1) : 0] output_val;
    wire output_valid, done;

    integer wait_cycles;

    reg [(`BIN_LEN - 1) : 0] input_vals [(`INPUT_HEIGHT - 1) : 0][(`INPUT_WIDTH - 1) : 0];

    reg [(`OUT_BIN_LEN - 1) : 0] result;

    processing_unit PU(
        .clock(clock),
        .reset(reset),
        .start(start),

        .input_req(input_req),
        .input_val(input_val),
        .input_ready(input_ready),


        .weight_vals(weight_vals),

        .output_val(output_val),
        .output_valid(output_valid),

        .done(done)
    );

    always begin
        #5;
        clock = ~clock;
    end

    initial begin
        clock = 0;
        reset = 0;
        start = 0;
        input_val = 0;
        input_ready = 0;
        for(int i = 0; i < `KERNEL_HEIGHT; i++) begin
            for(int j = 0; j < `KERNEL_WIDTH; j++) begin
                weight_vals[i][j] = 0;
            end
        end
        @(negedge clock);
        reset = 1;
        @(negedge clock);
        reset = 0;
        @(negedge clock);
        @(negedge clock);
        for(int i = 0; i < `KERNEL_HEIGHT; i++) begin
            for(int j = 0; j < `KERNEL_WIDTH; j++) begin
                weight_vals[i][j] = ($urandom() % 10) + (i * 30) * (j * 20);
            end
        end
        for(int i = 0; i < `INPUT_HEIGHT; i++) begin
            for(int j = 0; j < `INPUT_WIDTH; j++) begin
                input_vals[i][j] = ($urandom() % 40) + 10;
            end
        end
        start = 1;
        @(negedge clock);
        start = 0;
        for(int i = 0; i < `INPUT_HEIGHT; i++) begin
            for(int j = 0; j < `INPUT_WIDTH; j++) begin
                @(posedge input_req);
                wait_cycles = $urandom() % 5;
                for(int k = 0; k < wait_cycles; k++) begin
                    @(negedge clock);
                end
                input_val = input_vals[i][j];
                input_ready = 1;
                @(negedge clock);
                @(negedge clock);
                input_ready = 0;
                if(i >= (`KERNEL_HEIGHT - 1) && j >= (`KERNEL_WIDTH - 1)) begin
                    $display("waiting for output, i = %d, j = %d", i, j);
                    @(posedge output_valid);
                    result = 0;
                    for(int i_sel = 0; i_sel < `KERNEL_HEIGHT; i_sel++) begin
                        for(int j_sel = 0; j_sel < `KERNEL_WIDTH; j_sel++) begin
                            result = result + (input_vals[i - (`KERNEL_HEIGHT - 1) + i_sel][j - (`KERNEL_WIDTH - 1) + j_sel] * weight_vals[i_sel][j_sel])/64;
                        end
                    end
                    $display("output received. Expected: %d, Actual: %d", result, output_val);
                end
            end
        end
        $display("waiting for done flag");
        @(posedge done);
        $display("done received");
        $finish;
    end

endmodule
