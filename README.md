# 16-Tap FIR Filter (Verilog HDL)

This repository contains a fully-pipelined, synthesizable **16-tap FIR (Finite Impulse Response) digital filter** implemented in Verilog HDL. The design demonstrates fixed-point DSP implementation techniques, efficient multiply-accumulate hardware, pipelined arithmetic, and cycle-accurate verification using a self-checking testbench.

## Table of Contents
- **Author**
- **Introduction**
- **What Is Fixed-Point Arithmetic?**
- **FIR Filter Theory**
- **Coefficient Design**
- **Architecture Overview**
- **Detailed Module Descriptions**
  - Shift Register
  - Coefficient ROM
  - MAC Core
  - Top-Level Module
  - Self-Checking Testbench
- **Simulation Waveforms**
- **Possible Improvements**
- **Conclusion**
- **License**

## Author
**Rom Barak**  
B.Sc. Electrical Engineering, Bar-Ilan University  
Focus Areas: Nanoelectronics and Communication Systems

## Introduction
This project implements a low-pass FIR filter using **fixed-point arithmetic**, **pipelined MAC operations**, and a clean structural Verilog hierarchy.  
The complete design includes:

- A 16-tap serial input shift register  
- A signed 16-bit coefficient ROM (Q1.15 format)  
- A pipelined multiply–accumulate (MAC) engine producing a 36-bit output  
- A top-level module integrating all components  
- A comprehensive self-checking testbench with a software reference model  

The filter produces **one valid output per clock cycle** after a deterministic **two-cycle pipeline latency**.

## What Is Fixed-Point Arithmetic?
Hardware DSP systems rarely use floating-point because floating-point units are expensive in area, power, and latency.  
Instead, FIR filters in ASICs and FPGAs almost always rely on **fixed-point arithmetic**.

### Q1.15 Format (Used in this project)
- 1 sign bit  
- 15 fractional bits  
- Range: −1.0 to +0.99997  
- Resolution: 2⁻¹⁵ ≈ 3.05×10⁻⁵  

Multiplication:
- 16-bit × 16-bit → 32-bit product

Accumulation:
- Products are **sign-extended** to 36-bits  
- Prevents overflow during the sum of 16 taps  

This format is widely used in audio DSP, communication filters, and embedded hardware.

## FIR Filter Theory

A 16-tap FIR filter computes:

y[n] = Σ ( h[k] × x[n − k] ), for k = 0..15

Where:
- x[n] = input samples  
- h[k] = filter coefficients  
- Output is inherently stable (FIR filters are always stable)  
- Symmetric coefficients produce **linear-phase** filtering  

## Coefficient Design

The coefficients were generated using a standard FIR design procedure:

1. Selection of a desired **low-pass cutoff frequency**  
2. Design of a **symmetric** impulse response  
3. Quantization to **Q1.15 fixed-point**  
4. Export as signed 16-bit constants  

Coefficients used in this project:

-84, −53, 120, 240, 350, 420, 450, 460, 460, 450, 420, 350, 240, 120, −53, −84

Properties:
- Symmetric → linear phase  
- Smooth windowed shape → low ripple  
- Normalized to avoid overflow  

## Architecture Overview

The design is composed of four main hardware blocks:

| Block | Function |
|-------|----------|
| **Shift Register** | Stores the last 16 input samples |
| **Coefficient ROM** | Provides 16 constant Q1.15 coefficients |
| **MAC Core** | Pipelined multiply–accumulate engine |
| **Top Module** | Connects all blocks and defines the external interface |

**Pipeline Latency:** 2 cycles  
**Throughput:** 1 output sample per cycle  

## Module Descriptions (Expanded)

### Shift Register – 16-Tap Sample Delay Line
The shift register implements the required memory window for x[n], x[n−1], ..., x[n−15].

### Coefficient ROM – Signed Q1.15 FIR Taps
This module stores the filter coefficients.

### MAC Core – Pipelined Multiply–Accumulate Engine
This is the heart of the FIR filter.

### Top-Level Module – System Integration
This module binds everything together.

### Self-Checking Testbench – Full Behavioral Verification
A professional verification environment supporting:

## Simulation Waveforms

### Shift Register
![Shift Register](Assets/wave_shift_reg.png)

### MAC Pipeline (Part 1)
![MAC Part 1](Assets/wave_mac_part1.png)

### MAC Pipeline (Part 2)
![MAC Part 2](Assets/wave_mac_part2.png)

### MAC Pipeline (Part 3)
![MAC Part 3](Assets/wave_mac_part3.png)

### Stage1 Products
![Products](Assets/wave_mac_prod1.png)

### Output Latency
![Latency](Assets/wave_output_latency.png)

## Possible Improvements
1. Parametric number of taps  
2. Runtime-programmable coefficients  
3. Multi-channel filter bank support  
4. Additional pipeline stages for >500 MHz operation  
5. Floating-point version  
6. Polyphase filters for interpolation/decimation  
7. AXI-Stream interface for SoC integration  

## Conclusion
This project demonstrates a complete, high-quality **fixed-point FIR digital filter** implemented in Verilog.  
The design incorporates industry-standard DSP techniques such as pipelined MAC computation, Q-format arithmetic, balanced adder tree architecture, and full behavioral verification.

Because of its modular structure, deterministic timing, and synthesizability, this FIR filter is suitable both for educational purposes and real-world FPGA/ASIC DSP systems.

## License
This project is released for academic and educational use.  
Users may extend or modify the design with proper attribution.
