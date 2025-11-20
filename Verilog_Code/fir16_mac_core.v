// fir16_mac_core.v
// ----------------------------------------------------------------------------
// Description
// ----------------------------------------------------------------------------
// Pipelined multiply–accumulate (MAC) engine for a 16-tap fixed-point FIR filter.
// The module receives 16 input samples (packed into a 256-bit bus) and 16
// signed Q1.15 FIR coefficients.  
//
// Operation is performed in two pipeline stages:
//    Stage 1 — 16 parallel multipliers compute sample[i] * coeff[i]  
//    Stage 2 — a 4-level adder tree accumulates all products into a 36-bit sum  
//
// The 36-bit output y_out provides the fully filtered result with one output per
// clock cycle after initial pipeline latency.  All arithmetic is signed and
// properly sign-extended to prevent overflow during accumulation.
// ----------------------------------------------------------------------------

module fir16_mac_core (
    clk, reset,
    samples_flat,
    coeff0, coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7,
    coeff8, coeff9, coeff10, coeff11, coeff12, coeff13, coeff14, coeff15,
    y_out
);

    // Clock and reset
    input clk;
    input reset;

    // Packed 16 * 16-bit input samples
    input [255:0] samples_flat;

    // 16 signed FIR coefficients (Q1.15)
    input signed [15:0] coeff0,  coeff1,  coeff2,  coeff3;
    input signed [15:0] coeff4,  coeff5,  coeff6,  coeff7;
    input signed [15:0] coeff8,  coeff9,  coeff10, coeff11;
    input signed [15:0] coeff12, coeff13, coeff14, coeff15;

    // 36-bit MAC output
    output reg signed [35:0] y_out;

    // Unpacked samples (16-bit signed)
    wire signed [15:0] sample0,  sample1,  sample2,  sample3;
    wire signed [15:0] sample4,  sample5,  sample6,  sample7;
    wire signed [15:0] sample8,  sample9,  sample10, sample11;
    wire signed [15:0] sample12, sample13, sample14, sample15;

    assign sample0  = samples_flat[  15:  0];
    assign sample1  = samples_flat[  31: 16];
    assign sample2  = samples_flat[  47: 32];
    assign sample3  = samples_flat[  63: 48];
    assign sample4  = samples_flat[  79: 64];
    assign sample5  = samples_flat[  95: 80];
    assign sample6  = samples_flat[ 111: 96];
    assign sample7  = samples_flat[ 127:112];
    assign sample8  = samples_flat[ 143:128];
    assign sample9  = samples_flat[ 159:144];
    assign sample10 = samples_flat[ 175:160];
    assign sample11 = samples_flat[ 191:176];
    assign sample12 = samples_flat[ 207:192];
    assign sample13 = samples_flat[ 223:208];
    assign sample14 = samples_flat[ 239:224];
    assign sample15 = samples_flat[ 255:240];

    // Stage 1- registered products
    reg signed [31:0] prod0,  prod1,  prod2,  prod3;
    reg signed [31:0] prod4,  prod5,  prod6,  prod7;
    reg signed [31:0] prod8,  prod9,  prod10, prod11;
    reg signed [31:0] prod12, prod13, prod14, prod15;

    // 36-bit sign extension of all products
    wire signed [35:0] p0_ext,  p1_ext,  p2_ext,  p3_ext;
    wire signed [35:0] p4_ext,  p5_ext,  p6_ext,  p7_ext;
    wire signed [35:0] p8_ext,  p9_ext,  p10_ext, p11_ext;
    wire signed [35:0] p12_ext, p13_ext, p14_ext, p15_ext;

    assign p0_ext  = { {4{prod0[31]}},  prod0 };
    assign p1_ext  = { {4{prod1[31]}},  prod1 };
    assign p2_ext  = { {4{prod2[31]}},  prod2 };
    assign p3_ext  = { {4{prod3[31]}},  prod3 };
    assign p4_ext  = { {4{prod4[31]}},  prod4 };
    assign p5_ext  = { {4{prod5[31]}},  prod5 };
    assign p6_ext  = { {4{prod6[31]}},  prod6 };
    assign p7_ext  = { {4{prod7[31]}},  prod7 };
    assign p8_ext  = { {4{prod8[31]}},  prod8 };
    assign p9_ext  = { {4{prod9[31]}},  prod9 };
    assign p10_ext = { {4{prod10[31]}}, prod10 };
    assign p11_ext = { {4{prod11[31]}}, prod11 };
    assign p12_ext = { {4{prod12[31]}}, prod12 };
    assign p13_ext = { {4{prod13[31]}}, prod13 };
    assign p14_ext = { {4{prod14[31]}}, prod14 };
    assign p15_ext = { {4{prod15[31]}}, prod15 };

    // 4-level adder tree (combinational)
    wire signed [35:0] s0, s1, s2, s3, s4, s5, s6, s7;
    wire signed [35:0] t0, t1, t2, t3;
    wire signed [35:0] u0, u1;
    wire signed [35:0] final_sum;

    assign s0 = p0_ext  + p1_ext;
    assign s1 = p2_ext  + p3_ext;
    assign s2 = p4_ext  + p5_ext;
    assign s3 = p6_ext  + p7_ext;
    assign s4 = p8_ext  + p9_ext;
    assign s5 = p10_ext + p11_ext;
    assign s6 = p12_ext + p13_ext;
    assign s7 = p14_ext + p15_ext;

    assign t0 = s0 + s1;
    assign t1 = s2 + s3;
    assign t2 = s4 + s5;
    assign t3 = s6 + s7;

    assign u0 = t0 + t1;
    assign u1 = t2 + t3;

    assign final_sum = u0 + u1;

    // Pipeline registers (Stage 1 = products, Stage 2 = final sum)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prod0  <= 0;  prod1  <= 0;  prod2  <= 0;  prod3  <= 0;
            prod4  <= 0;  prod5  <= 0;  prod6  <= 0;  prod7  <= 0;
            prod8  <= 0;  prod9  <= 0;  prod10 <= 0;  prod11 <= 0;
            prod12 <= 0;  prod13 <= 0;  prod14 <= 0;  prod15 <= 0;
            y_out <= 0;
        end else begin
            // Stage 1: parallel multipliers
            prod0  <= sample0  * coeff0;
            prod1  <= sample1  * coeff1;
            prod2  <= sample2  * coeff2;
            prod3  <= sample3  * coeff3;
            prod4  <= sample4  * coeff4;
            prod5  <= sample5  * coeff5;
            prod6  <= sample6  * coeff6;
            prod7  <= sample7  * coeff7;
            prod8  <= sample8  * coeff8;
            prod9  <= sample9  * coeff9;
            prod10 <= sample10 * coeff10;
            prod11 <= sample11 * coeff11;
            prod12 <= sample12 * coeff12;
            prod13 <= sample13 * coeff13;
            prod14 <= sample14 * coeff14;
            prod15 <= sample15 * coeff15;

            // Stage 2: accumulated output
            y_out <= final_sum;
        end
    end

endmodule
