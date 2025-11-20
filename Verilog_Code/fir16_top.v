// fir16_top.v
// ----------------------------------------------------------------------------
// Description
// ----------------------------------------------------------------------------
// Top-level integration module for a 16-tap fixed-point FIR filter.
// It connects the three building blocks of the filter:
//
//    Shift Register  – stores the last 16 input samples (x[n] to x[n-15])
//    Coefficient ROM – provides 16 signed Q1.15 FIR coefficients
//    MAC Core        – performs the pipelined 16-tap multiply–accumulate
//
// The module accepts one 16-bit signed input sample per clock cycle and outputs
// a fully filtered 36-bit result after the 2-stage MAC pipeline latency.
// ----------------------------------------------------------------------------

module fir16_top (clk, reset, sample_in, y_out);

    // Clock and reset
    input clk;
    input reset;

    // Input sample (signed 16-bit)
    input  signed [15:0] sample_in;

    // Filtered output (signed 36-bit)
    output signed [35:0] y_out;

    // Packed shift-register taps
    wire [255:0] samples_flat;

    // FIR coefficient wires (Q1.15)
    wire signed [15:0] coeff0,  coeff1,  coeff2,  coeff3;
    wire signed [15:0] coeff4,  coeff5,  coeff6,  coeff7;
    wire signed [15:0] coeff8,  coeff9,  coeff10, coeff11;
    wire signed [15:0] coeff12, coeff13, coeff14, coeff15;

    // Shift register (tap memory)
    fir16_shift_reg shift_reg_inst (
        .clk          (clk),
        .reset        (reset),
        .sample_in    (sample_in),
        .samples_flat (samples_flat)
    );

    // Coefficient ROM (fixed FIR kernel)
    fir16_coeff_rom coeff_rom_inst (
        .coeff0  (coeff0),
        .coeff1  (coeff1),
        .coeff2  (coeff2),
        .coeff3  (coeff3),
        .coeff4  (coeff4),
        .coeff5  (coeff5),
        .coeff6  (coeff6),
        .coeff7  (coeff7),
        .coeff8  (coeff8),
        .coeff9  (coeff9),
        .coeff10 (coeff10),
        .coeff11 (coeff11),
        .coeff12 (coeff12),
        .coeff13 (coeff13),
        .coeff14 (coeff14),
        .coeff15 (coeff15)
    );

    // MAC core (16 parallel multipliers + adder tree)
    fir16_mac_core mac_inst (
        .clk          (clk),
        .reset        (reset),
        .samples_flat (samples_flat),
        .coeff0       (coeff0),
        .coeff1       (coeff1),
        .coeff2       (coeff2),
        .coeff3       (coeff3),
        .coeff4       (coeff4),
        .coeff5       (coeff5),
        .coeff6       (coeff6),
        .coeff7       (coeff7),
        .coeff8       (coeff8),
        .coeff9       (coeff9),
        .coeff10      (coeff10),
        .coeff11      (coeff11),
        .coeff12      (coeff12),
        .coeff13      (coeff13),
        .coeff14      (coeff14),
        .coeff15      (coeff15),
        .y_out        (y_out)
    );

endmodule
