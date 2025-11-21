# 16‑Tap FIR Filter (Verilog HDL)

This repository contains a fully‑pipelined, synthesizable **16‑tap FIR (Finite Impulse Response) digital filter** implemented in Verilog HDL.  
The design demonstrates fixed‑point DSP implementation techniques, efficient multiply‑accumulate hardware, pipelined arithmetic, and cycle‑accurate verification using a self‑checking testbench.

---

## Author
**Rom Barak**  
B.Sc. Electrical Engineering, Bar‑Ilan University  
Focus Areas: Nanoelectronics and Communication Systems

---

## Introduction
This project implements a low‑pass FIR filter using fixed‑point arithmetic, pipelined MAC operations, and a clean structural Verilog architecture.  
The system computes one filtered output sample per clock cycle after a fixed **2‑cycle pipeline latency**, making it suitable for high‑throughput DSP hardware.

---

## What Is Fixed‑Point Arithmetic?
Hardware DSP systems rarely use floating‑point due to area, latency, and power cost.  
Instead, FIR filters almost always use **fixed‑point formats**.

### Q1.15 Format (Used in This Design)
- 1 sign bit  
- 15 fractional bits  
- Range: −1.0 to +0.99997  
- Resolution: 2⁻¹⁵ ≈ 3.05×10⁻⁵  

Multiplication produces:
```
16‑bit × 16‑bit → 32‑bit product
```

To safely accumulate 16 products:
```
Products are sign‑extended: 32 → 36 bits
```

---

## FIR Filter Theory
A 16‑tap FIR filter computes:

y[n] = Σ h[k] · x[n−k]   (k = 0…15)

- x[n] – input samples  
- h[k] – filter coefficients  
- Stability is guaranteed (FIR filters are always stable)  
- Symmetry ensures linear phase  

---

## Coefficient Design
The coefficients were designed offline using a classical low‑pass filter design flow:

1. Select cutoff frequency  
2. Generate ideal impulse response  
3. Apply windowing  
4. Enforce symmetry  
5. Quantize to Q1.15  
6. Export as signed 16‑bit integers  

Final taps used:

```
[-84, -53, 120, 240, 350, 420, 450, 460,
  460, 450, 420, 350, 240, 120, -53, -84]
```

### Properties
- Symmetric → linear‑phase  
- Smooth shape → low passband ripple  
- Sum(h) < 1 → overflow‑safe  

---

## Architecture Overview
Four hardware blocks form the full filter:

| Block | Description |
|-------|-------------|
| **Shift Register** | Holds x[n] … x[n−15] in 16 pipeline registers |
| **Coefficient ROM** | Outputs 16 constant Q1.15 coefficients |
| **MAC Core** | Performs 16 parallel multiplications + pipelined adder tree |
| **Top Module** | Structural integration of the entire filter |

### Pipeline timing
- **Latency:** 2 cycles  
- **Throughput:** 1 output per cycle  

---

## Module Descriptions

### Shift Register
Stores the last 16 input samples.  
Each cycle:
- tap15 <= tap14  
- …  
- tap1 <= tap0  
- tap0 <= sample_in  

Produces packed 256‑bit bus `samples_flat`.

**Waveform:**  
![Shift Register](Assets/wave_shift_reg.png)

---

### Coefficient ROM
Implements 16 signed constants in Q1.15 format using `assign` statements.

Features:
- Zero latency  
- Fully synthesizable  
- Symmetric coefficient set

---

### MAC Core
This is the computational engine of the filter.

**Pipeline Stages**
1. **Stage 1 – Parallel Multipliers**  
   - 16 multipliers  
   - Each result stored in `prodX` registers

   ![MAC Products 1](Assets/wave_mac_prod1.png)  
   ![MAC Products 2](Assets/wave_mac_prod2.png)  
   ![MAC Products 3](Assets/wave_mac_prod3.png)

2. **Sign Extension**  
   Convert 32‑bit products → 36‑bit for safe accumulation

3. **Adder Tree (Combinational)**  
   Four‑level balanced tree:  
   ```
   16 → 8 → 4 → 2 → 1
   ```  
   ![MAC Part 1](Assets/wave_mac_part1.png)  
   ![MAC Part 2](Assets/wave_mac_part2.png)  
   ![MAC Part 3](Assets/wave_mac_part3.png)

4. **Stage 2 – Output Register**  
   Stores `final_sum` into `y_out`.

**Latency Visualization:**  
![Output Latency](Assets/wave_output_latency.png)

---

## Self‑Checking Testbench
Features:
- Clock and reset generation  
- Reference FIR model identical to DUT  
- 2‑cycle matching delay  
- Automatic pass/fail checking  
- VCD dump for waveform analysis  

Stimuli include:
- Ramp  
- Step  
- Alternating ±100  
- Reset behavior  

If `y_out` ≠ reference, the simulation stops immediately.

---

## Simulation Waveforms
Included waveforms show:

1. Correct tap‑flow inside shift‑register  
2. Stable MAC multipliers  
3. Balanced 36‑bit adder tree  
4. 2‑cycle latency between input and output  
5. Perfect match between DUT and software model  

---

## Possible Improvements
Future enhancements can include:

- Dynamic coefficient loading  
- Larger tap support (32, 64, 128…)  
- Polyphase design for interpolation / decimation  
- FPGA DSP‑slice optimization  
- AXI‑Stream or Avalon streaming interface  
- Fixed‑ vs floating‑point hybrid processing  

---

## Conclusion
This project demonstrates a complete, highly accurate, fully pipelined FIR filter implemented in Verilog HDL.  
It highlights key DSP hardware concepts such as:

- Q‑format arithmetic  
- Multiply‑accumulate pipelines  
- Balanced adder trees  
- Deterministic latency design  
- Automated testbench verification  

The modular structure makes this design ideal for FPGA, ASIC, or academic DSP work.

---

## License
Released for educational and academic use.  
May be modified or extended with attribution.

