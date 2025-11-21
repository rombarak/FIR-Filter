# **16-Tap FIR Filter (Verilog HDL)**

This repository contains a fully-pipelined, synthesizable **16-tap FIR (Finite Impulse Response) filter** implemented in Verilog HDL.  
The design demonstrates fixed-point DSP techniques, deterministic pipelining, a balanced adder tree, and full cycle-accurate verification using a self-checking testbench.

---

## **Table of Contents**
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
  - [Top-Level](#top-level)
  - [Self-Checking Testbench](#self-checking-testbench)
- [Simulation Waveforms](#simulation-waveforms)
- [Possible Improvements](#possible-improvements)
- [Conclusion](#conclusion)
- [License](#license)

---

## **Author**
**Rom Barak**  
B.Sc. Electrical Engineering, Bar-Ilan University  
Focus: Digital Design, Fixed-Point DSP, RTL Architecture, VLSI Logic

---

## **Introduction**

This project implements a complete **fixed-point low-pass FIR filter** using:

- 16-tap input shift register  
- Constant Q1.15 coefficients  
- Two-stage pipelined MAC core  
- Balanced 36-bit adder tree  
- Fully self-checking testbench  

The design outputs **one filtered sample per clock** with a deterministic **two-cycle latency**  
and is fully synthesizable for FPGA/ASIC integration.

---

## **What Is Fixed-Point Arithmetic?**

Fixed-point (Q-format) is widely used in hardware DSP due to:

- Low area and power
- Deterministic rounding/overflow
- Reproducible bit-accurate behavior
- Efficient synthesis and timing closure

### **Q1.15 Format (Used Here)**

- 1 sign bit  
- 15 fractional bits  
- Range: −1.0 ≤ x < +1.0  
- Resolution ≈ 3.05×10⁻⁵  

Multiplications:  
- 16-bit × 16-bit → 32-bit  
- Summing 16 products → extended to **36 bits** to avoid overflow.

---

## **FIR Filter Theory**

A 16-tap FIR computes:

\[
y[n] = \sum_{k=0}^{15} h[k] \cdot x[n-k]
\]

FIR properties:

- Always stable  
- Linear phase (symmetric coefficients)  
- Deterministic timing  
- Ideal for audio, comms, and sensor filtering

---

## **Coefficient Design**

The filter uses the following **symmetric low-pass FIR coefficients**:

    [-84, -53, 120, 240, 350, 420, 450, 460,
     460, 450, 420, 350, 240, 120, -53, -84]


Why they were chosen:

- Symmetry → linear phase  
- Smooth shape → good attenuation  
- Normalized → avoids internal overflow  
- 16 taps → optimal area/latency tradeoff  

---

## **Architecture Overview**

| Block | Description |
|-------|-------------|
| **Shift Register** | Stores the last 16 samples |
| **Coefficient ROM** | Provides Q1.15 taps |
| **MAC Core** | 16 multipliers + 36-bit adder tree |
| **Top-Level** | Wiring + control |
| **Testbench** | Full cycle-accurate verification |

**Latency:** 2 cycles  
**Throughput:** 1 output/clock  

---

# 🧩 **Module Descriptions**

---

## **Shift Register**

Stores 16 sequential samples (`tap0` = newest).  
Provides a stable 256-bit packed bus to the MAC core.

**Waveform:**  
![Shift Register](Assets/wave_shift_reg.png)

*Shows correct shifting of samples each cycle and proper reset initialization.*

---

## **Coefficient ROM**

Provides 16 constant signed Q1.15 coefficients.  
Zero latency, fully synthesizable.

---

## **MAC Core**

### **Stage 1 — Parallel Multipliers**

Each tap × coefficient pair is multiplied in parallel  
and stored in 32-bit registers.

**Waveforms:**  
![MAC Products 1](Assets/wave_mac_prod1.png)  
![MAC Products 2](Assets/wave_mac_prod2.png)  
![MAC Products 3](Assets/wave_mac_prod3.png)

*Shows correct multiplier timing and stable registered outputs.*

---

### **Stage 2 — 36-bit Adder Tree**

A balanced four-stage adder tree reduces:

16 → 8 → 4 → 2 → 1

**Waveforms:**  
![MAC Part 1](Assets/wave_mac_part1.png)  
![MAC Part 2](Assets/wave_mac_part2.png)  
![MAC Part 3](Assets/wave_mac_part3.png)

*Shows progressive accumulation of partial sums without overflow.*

---

### **Final Pipeline Stage**

Registers the final 36-bit result → ensures deterministic 2-cycle latency.

**Waveform:**  
![Output Latency](Assets/wave_output_latency.png)

*Shows exact 2-cycle delay between input activity and final output.*

---

## **Top-Level**

Connects the entire FIR structure:
sample_in ──► shift_reg ──► samples_flat  
(samples_flat, coeffs) ──► MAC ──► y_out



Clock/reset propagate synchronously to ensure stable timing.

---

## **Self-Checking Testbench**

Features:

- Software reference FIR  
- 2-cycle aligned comparison  
- Automatic mismatch detection  
- Stimuli: ramp, step, alternating, random  
- Generates `dump.vcd` for waveform inspection

---

## **Possible Improvements**

- Programmable coefficients  
- 32/64/128-tap variants  
- Deeper pipelining (>500 MHz)  
- SIMD multi-channel FIR  
- AXI-Stream interface  
- Half-band / polyphase design  

---

## **Conclusion**

This project demonstrates a modular, synthesizable, pipelined FIR filter with:

- Q-format arithmetic  
- Parallel multipliers  
- Balanced adder tree  
- Deterministic timing  
- Self-checking verification  

Ideal for FPGA, ASIC, and DSP learning environments.

---

## **License**

Open for academic and educational use.  
Modifications are welcome with credit.

