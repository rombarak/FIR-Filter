// fir16_tb.v
// ----------------------------------------------------------------------------
// Description
// ----------------------------------------------------------------------------
// Self-checking testbench for the 16-tap FIR filter.
// The testbench instantiates the DUT, generates a clock, records waveforms,
// and includes a full behavioral FIR reference model.
//
// The reference model mirrors the DUT’s structure:
//    Shift register for input samples
//    16-tap multiply-accumulate (combinational)
//    2-stage pipeline delay (matching the MAC core)
//
// The checker automatically compares DUT output against the reference with
// warm-up cycles to account for pipeline latency. Any mismatch stops the
// simulation. Three input patterns are tested: ramp, step, and alternating noise.
// ----------------------------------------------------------------------------

`timescale 1ns/1ps

module fir16_tb;

    // DUT interface
    reg clk;
    reg reset;
    reg signed [15:0] sample_in;
    wire signed [35:0] y_out;

    // DUT instance
    fir16_top dut (
        .clk       (clk),
        .reset     (reset),
        .sample_in (sample_in),
        .y_out     (y_out)
    );

    // Clock + waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, fir16_tb);

        clk = 0;
        forever #5 clk = ~clk;      // 100 MHz clock
    end

    // Reference FIR model
    reg signed [15:0] ref_tap[0:15];
    reg signed [35:0] ref_sum;
    reg signed [35:0] ref_y_delayed[0:1];
    reg signed [15:0] coeff[0:15];

    integer k;

    initial begin
        // FIR coefficients (identical to DUT)
        coeff[0]  = -16'sd84;
        coeff[1]  = -16'sd53;
        coeff[2]  =  16'sd120;
        coeff[3]  =  16'sd240;
        coeff[4]  =  16'sd350;
        coeff[5]  =  16'sd420;
        coeff[6]  =  16'sd450;
        coeff[7]  =  16'sd460;
        coeff[8]  =  16'sd460;
        coeff[9]  =  16'sd450;
        coeff[10] =  16'sd420;
        coeff[11] =  16'sd350;
        coeff[12] =  16'sd240;
        coeff[13] =  16'sd120;
        coeff[14] = -16'sd53;
        coeff[15] = -16'sd84;

        // Clear reference state
        for (k = 0; k < 16; k = k + 1)
            ref_tap[k] = 0;

        ref_y_delayed[0] = 0;
        ref_y_delayed[1] = 0;
    end

    // Reference shift register
    always @(posedge clk) begin
        if (reset) begin
            for (k = 0; k < 16; k = k + 1)
                ref_tap[k] <= 0;

            ref_y_delayed[0] <= 0;
            ref_y_delayed[1] <= 0;
        end
        else begin
            for (k = 15; k > 0; k = k - 1)
                ref_tap[k] <= ref_tap[k-1];

            ref_tap[0] <= sample_in;
        end
    end

    // Reference MAC (combinational)
    always @(*) begin
        ref_sum = 0;
        for (k = 0; k < 16; k = k + 1)
            ref_sum = ref_sum + coeff[k] * ref_tap[k];
    end

    // Reference pipeline (2-cycle latency)
    always @(posedge clk) begin
        ref_y_delayed[1] <= ref_y_delayed[0];
        ref_y_delayed[0] <= ref_sum;
    end

    // Checker warm-up for pipeline alignment
    reg check_enable;
    integer warmup_count;

    initial begin
        check_enable = 0;
        warmup_count = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            warmup_count <= 0;
            check_enable <= 0;
        end
        else if (warmup_count < 6)
            warmup_count <= warmup_count + 1;
        else
            check_enable <= 1;
    end

    // Self-checking logic
    always @(posedge clk) begin
        if (!reset && check_enable) begin
            if (y_out !== ref_y_delayed[1]) begin
                $display("ERROR at %0t: y_out=%0d, expected=%0d",
                         $time, y_out, ref_y_delayed[1]);
                $stop;
            end
        end
    end

    // Test stimulus
    integer i;

    initial begin
        sample_in = 0;
        reset = 1;

        #20 reset = 0;

        // Ramp
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            sample_in <= i;
        end

        // Step
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            sample_in <= 16'sd200;
        end

        // Alternating noise
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            sample_in <= (i % 2) ? 16'sd100 : -16'sd100;
        end

        $display("All tests passed. FIR output matches reference model.");
        $stop;
    end

endmodule
