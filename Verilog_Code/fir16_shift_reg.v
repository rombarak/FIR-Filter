// fir16_shift_reg.v
// ----------------------------------------------------------------------------
// Description
// ----------------------------------------------------------------------------
// 16-tap shift register used in a fixed-point FIR filter. On every clock edge,
// the newest input sample x[n] is loaded into tap0, while all previous samples
// shift down one position (tap1 ← tap0, tap2 ← tap1, … tap15 ← tap14).  
//
// The module outputs all 16 taps as a single packed 256-bit bus
// (16 taps × 16 bits), allowing the MAC stage to access the entire window of
// samples in parallel during convolution.
// ----------------------------------------------------------------------------

module fir16_shift_reg (clk, reset, sample_in, samples_flat);

  // Inputs
  input clk;                      // system clock
  input reset;                    // async reset
  input signed [15:0] sample_in;  // newest sample x[n]

  // Outputs
  output [255:0] samples_flat;    // packed taps vector

  // 16 tap registers (x[n]..x[n-15])
  reg signed [15:0] tap0, tap1, tap2, tap3, tap4, tap5, tap6, tap7;
  reg signed [15:0] tap8, tap9, tap10, tap11, tap12, tap13, tap14, tap15;

  // Shift operation
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      tap0  <= 0; tap1  <= 0; tap2  <= 0; tap3  <= 0;
      tap4  <= 0; tap5  <= 0; tap6  <= 0; tap7  <= 0;
      tap8  <= 0; tap9  <= 0; tap10 <= 0; tap11 <= 0;
      tap12 <= 0; tap13 <= 0; tap14 <= 0; tap15 <= 0;
    end else begin
      tap15 <= tap14;
      tap14 <= tap13;
      tap13 <= tap12;
      tap12 <= tap11;
      tap11 <= tap10;
      tap10 <= tap9 ;
      tap9  <= tap8 ;
      tap8  <= tap7 ;
      tap7  <= tap6 ;
      tap6  <= tap5 ;
      tap5  <= tap4 ;
      tap4  <= tap3 ;
      tap3  <= tap2 ;
      tap2  <= tap1 ;
      tap1  <= tap0 ;

      tap0  <= sample_in;     // x[n]
    end
  end

  // Packed 256-bit output (tap0 = LSB)
  assign samples_flat[  15:  0] = tap0;
  assign samples_flat[  31: 16] = tap1;
  assign samples_flat[  47: 32] = tap2;
  assign samples_flat[  63: 48] = tap3;
  assign samples_flat[  79: 64] = tap4;
  assign samples_flat[  95: 80] = tap5;
  assign samples_flat[ 111: 96] = tap6;
  assign samples_flat[ 127:112] = tap7;
  assign samples_flat[ 143:128] = tap8;
  assign samples_flat[ 159:144] = tap9;
  assign samples_flat[ 175:160] = tap10;
  assign samples_flat[ 191:176] = tap11;
  assign samples_flat[ 207:192] = tap12;
  assign samples_flat[ 223:208] = tap13;
  assign samples_flat[ 239:224] = tap14;
  assign samples_flat[ 255:240] = tap15;

endmodule
