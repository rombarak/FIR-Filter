# 16-Tap FIR Filter (Verilog HDL)

This repository contains a fully-pipelined, synthesizable **16-tap FIR (Finite Impulse Response) digital filter** implemented in Verilog HDL.  
The design demonstrates fixed-point DSP implementation techniques, efficient multiply-accumulate hardware, pipelined arithmetic, and cycle-accurate verification using a self-checking testbench.

---

## Table of Contents
- [Author](#author)
- [Introduction](#introduction)
- [What Is Fixed-Point Arithmetic?](#what-is-fixed-point-arithmetic)
- [FIR Filter Theory](#fir-filter-theory)
- [Coefficient Design](#coefficient-design)
- [Architecture Overview](#architecture-overview)
- [Module Descriptions](#module-descriptions)
  - [Shift Register](#shift-register)
  - [Coefficient ROM](#coefficient-rom)
  - [MAC Core](#mac-core)
  - [Top-Level Module](#top-level-module)
  - [Self-Checking Testbench](#self-checking-testbench)
- [Simulation Waveforms](#simulation-waveforms)
- [Possible Improvements](#possible-improvements)
- [Conclusion](#conclusion)
- [License](#license)

---

## Author
**Rom Barak**  
B.Sc. Electrical Engineering, Bar-Ilan University  
Focus Areas: Nanoelectronics and Communication Systems

---

## Introduction
This project implements a low-pass FIR filter using **fixed-point arithmetic**, **pipelined MAC operations**, and a **structural Verilog design** consisting of:

- 16-tap serial input shift-register
- Signed 16-bit coefficient ROM (Q1.15 format)
- Pipelined MAC engine producing a 36-bit output
- Top-level module integrating all components
- Complete self-checking testbench comparing DUT output to a reference model

The filter provides **one valid output sample per clock cycle** after two cycles of pipeline latency.

---

## What Is Fixed-Point Arithmetic?
In digital signal processing hardware, floating-point units are expensive in area, latency, and power.  
Therefore, FIR filters in ASICs and FPGAs are almost always implemented using **fixed-point arithmetic**.

### Q1.15 Format (Used Here)
- **1 sign bit**
- **15 fractional bits**
- Range: −1.0 to +0.99997  
- Resolution: \( 2^{-15} \approx 3.05 \times 10^{-5} \)

When multiplying:
```
16-bit × 16-bit → 32-bit
```
To accumulate safely across 16 taps:
```
32-bit products -> sign-extended to 36 bits
```

This prevents overflow inside the adder tree.

---

## FIR Filter Theory
A 16-tap FIR computes:

\[
y[n] = \sum_{k=0}^{15} h[k] \cdot x[n - k]
\]

Where:
- \(x[n]\) = input samples  
- \(h[k]\) = filter coefficients  
- Output is guaranteed stable (FIR filters are always stable)

For a **low-pass filter**, coefficients are typically symmetric and smooth, providing:

- Passband preservation  
- Stopband attenuation  
- Linear phase due to symmetry

---

## Coefficient Design
The coefficients were generated offline using a standard FIR design flow:

1. **Select cutoff frequency** (low-pass)
2. **Design symmetric taps**  
3. **Quantize to Q1.15 fixed-point**
4. **Export signed 16-bit constants**

Example taps (used in this design):

```
h = [-84, -53, 120, 240, 350, 420, 450, 460,
      460, 450, 420, 350, 240, 120, -53, -84]
```

Properties:
- Symmetric -> linear phase
- Smooth shape -> low ripple
- Normalized so that sum(h) < 1 to avoid overflow

---

## Architecture Overview
The design is divided into four hardware blocks:

| Block | Function |
|-------|----------|
| **Shift Register** | Stores last 16 samples (x[n], x[n-1], …) |
| **Coefficient ROM** | Outputs 16 constant Q1.15 coefficients |
| **MAC Core** | Pipelined multiply-accumulate engine |
| **Top Module** | Connects all modules |

Pipeline latency: **2 cycles**  
Throughput: **1 filtered output every cycle**

---

## Module Descriptions

### Shift Register
- 16 cascaded 16-bit registers  
- Newest sample enters `tap0`  
- Oldest sample exits `tap15`  
- Outputs a packed 256-bit bus

### Coefficient ROM
- 16 constant signed 16-bit values  
- Stored as Verilog `assign` statements  
- Format: Q1.15 fixed-point

### MAC Core
The heart of the FIR filter.

Stages:
1. **Stage 1:**  
   16 parallel multiplications  
   -> each product stored in 32-bit registers
2. **Sign Extension:**  
   Extend 32→36 bits to avoid overflow
3. **Adder Tree:**  
   Balanced 36-bit tree to sum 16 values
4. **Stage 2:**  
   Pipeline register storing final sum

Output: signed 36-bit filtered sample

### Top-Level Module
Connects:
- Shift register
- Coefficient ROM
- MAC core

Provides the user interface:
```
clk, reset, sample_in → y_out
```

### Self-Checking Testbench
The testbench provides:

- Clock/reset generation  
- A software FIR model (reference)  
- Automatic comparison with `y_out`  
- VCD waveform dump  
- Random, step, ramp, and alternating patterns

If a mismatch occurs, the testbench stops immediately.

---

## Simulation Waveforms
Recommended waveform captures to include:

1. **Shift Register Operation**  
   - Show `sample_in` flowing through taps  
   - Show packed `samples_flat`

2. **MAC Pipeline Behavior**  
   - `prodX` signals at Stage 1  
   - `final_sum` before Stage 2  
   - `y_out` after pipeline

3. **Reference vs. DUT Output**  
   - `y_out`  
   - `ref_y_delayed[1]`  
   - Both should match exactly

4. **Reset and Warmup Behavior**  
   - Clear taps  
   - Enable checker after 6 cycles

You can upload clean screenshots taken from EPWave/GTKWave.

---

## Possible Improvements
The architecture can be extended with:

1. **Configurable number of taps**
2. **Runtime-programmable coefficients**
3. **Multi-channel parallelism**
4. **Higher-order pipelining for 500–800 MHz operation**
5. **Support for floating-point coefficients**
6. **Polyphase structure for interpolation/decimation**
7. **AXI-Stream interface for SoC integration**

---

## Conclusion
This project demonstrates a complete and verified **fixed-point digital filter** implemented in Verilog.  
It covers essential DSP hardware concepts including pipelining, multiply-accumulate datapaths, Q-format arithmetic, and self-checking verification.  
The modular design, clean interface, and deterministic latency make it suitable for FPGA/ASIC integration, as well as an educational reference for FIR hardware implementation.

---

## License
This project is released for educational and academic use.  
Users may modify or extend the design with proper attribution.

