// fir16_coeff_rom.v
// ----------------------------------------------------------------------------
// Description
// ----------------------------------------------------------------------------
// Constant-coefficient ROM for a 16-tap fixed-point FIR filter.
// Each coefficient is a signed 16-bit value (Q1.15 format).  
// The module outputs all 16 coefficients in parallel, allowing the MAC stage
// to access them simultaneously during convolution.  
//
// The coefficients form a symmetric low-pass FIR kernel, commonly used for
// smoothing / noise reduction / anti-alias filtering.  
// ----------------------------------------------------------------------------

module fir16_coeff_rom (
    coeff0,  coeff1,  coeff2,  coeff3,
    coeff4,  coeff5,  coeff6,  coeff7,
    coeff8,  coeff9,  coeff10, coeff11,
    coeff12, coeff13, coeff14, coeff15
);

    // 16 signed FIR coefficients (Q1.15)
    output signed [15:0] coeff0;
    output signed [15:0] coeff1;
    output signed [15:0] coeff2;
    output signed [15:0] coeff3;
    output signed [15:0] coeff4;
    output signed [15:0] coeff5;
    output signed [15:0] coeff6;
    output signed [15:0] coeff7;
    output signed [15:0] coeff8;
    output signed [15:0] coeff9;
    output signed [15:0] coeff10;
    output signed [15:0] coeff11;
    output signed [15:0] coeff12;
    output signed [15:0] coeff13;
    output signed [15:0] coeff14;
    output signed [15:0] coeff15;

    // Fixed low-pass FIR coefficients (symmetric kernel)
    assign coeff0  = -16'sd84;
    assign coeff1  = -16'sd53;
    assign coeff2  =  16'sd120;
    assign coeff3  =  16'sd240;
    assign coeff4  =  16'sd350;
    assign coeff5  =  16'sd420;
    assign coeff6  =  16'sd450;
    assign coeff7  =  16'sd460;
    assign coeff8  =  16'sd460;
    assign coeff9  =  16'sd450;
    assign coeff10 =  16'sd420;
    assign coeff11 =  16'sd350;
    assign coeff12 =  16'sd240;
    assign coeff13 =  16'sd120;
    assign coeff14 = -16'sd53;
    assign coeff15 = -16'sd84;

endmodule
