# DFT-Aware Sequential Shift-and-Add Multiplier

An **8-bit Sequential Shift-and-Add Multiplier** implemented in **Verilog HDL** with **Design for Testability (DFT)** enhancements. The design incorporates **Integrated Clock Gating (ICG)** for low-power operation, **clock controllability**, **full scan chain insertion**, and a **DFT-aware verification environment** for manufacturing test support.

---

## Project Overview

This project extends a conventional sequential multiplier by integrating industry-standard DFT techniques commonly used in ASIC design flows. The objective is to maintain functional correctness while improving testability and reducing dynamic power consumption through clock gating.

### Features

- 8-bit Sequential Shift-and-Add Multiplier
- FSM-Based Controller
- Integrated Clock Gating (ICG)
- Test Mode Clock Gate Bypass
- Full 32-Bit Scan Chain
- Scan Shift and Capture Operations
- At-Speed Capture Support
- DFT-Compliant RTL Design
- Comprehensive Verification Testbench

---

# Design Architecture

The complete RTL design is organized into the following modules:

```
rtl/
├── ICG.v
├── bit_counter.v
├── controller.v
├── mult_regs.v
└── seq_multiplier.v
```

## Module Description

| Module | Description |
|---------|-------------|
| `ICG.v` | Integrated Clock Gate (ICG) with functional enable and test bypass |
| `controller.v` | Finite State Machine controlling multiplier operations |
| `mult_regs.v` | Datapath registers containing Accumulator (A), Multiplicand (M), and Multiplier (Q) |
| `bit_counter.v` | Clock-gated counter with scan support |
| `seq_multiplier.v` | Top-level integration of datapath, controller, scan chain, and DFT signals |

---

# Design for Testability (DFT)

## Clock Controllability

The original implementation gated the counter clock using `count_en`, preventing scan operations whenever the counter was disabled.

The modified design introduces an **Integrated Clock Gate (ICG)** that supports **test_mode**, allowing the clock gate to be bypassed during manufacturing test.

### Functional Mode

```
clk
 │
 ▼
ICG (enable = count_en)
 │
 ▼
Bit Counter
```

### Test Mode

```
clk
 │
 ▼
ICG (test_enable = 1)
 │
 ▼
Bit Counter
```

This ensures complete clock controllability without affecting functional timing.

---

## Full Scan Chain

All sequential elements are connected into a single serial scan chain.

```
scan_in
   │
   ▼
Controller State (3 bits)
   │
   ▼
Accumulator A (9 bits)
   │
   ▼
Multiplicand M (8 bits)
   │
   ▼
Multiplier Q (8 bits)
   │
   ▼
Bit Counter (4 bits)
   │
   ▼
scan_out
```

**Total Scan Chain Length = 32 Flip-Flops**

---

# Operating Modes

## Functional Mode

```
test_mode   = 0
scan_enable = 0
```

- Clock gating enabled
- Normal multiplier operation
- Low dynamic power consumption

---

## Scan Shift Mode

```
test_mode   = 1
scan_enable = 1
```

- Clock gate bypassed
- Serial scan data shifted into registers
- Full scan controllability

---

## Capture Mode

```
test_mode   = 1
scan_enable = 0
```

- Clock gate bypassed
- One functional clock applied
- Functional response captured for ATPG

---

# Verification

A DFT-aware testbench validates both functional correctness and scan functionality.

## Test C1 – Functional Verification

- Perform multiplication **13 × 11**
- Verify product = **143**
- Monitor gated clock activity
- Measure clock gating effectiveness

---

## Test C2 – Scan Shift Verification

- Enable test mode
- Shift a complete 32-bit scan pattern
- Verify all scan registers
- Confirm scan operation with `count_en = 0`

---

## Test C3 – Shift–Capture–Shift

- Shift ATPG pattern into scan chain
- Apply one capture clock
- Shift captured response out
- Compare with expected golden response

---

## Test C4 – At-Speed Capture

- Load counter through scan chain
- Apply one functional capture clock
- Verify counter increment
- Verify `last` signal assertion
- Demonstrate identical timing behavior in both functional and test modes

---

# Simulation

## Compile (Icarus Verilog)

```bash
iverilog -o multiplier_sim rtl/*.v tb/tb_seq_multiplier_dft.v
```

## Run Simulation

```bash
vvp multiplier_sim
```

## View Waveforms

```bash
gtkwave vcd/seq_mult_dft.vcd
```

or

```bash
gtkwave vcd/multiplier_tb_gtk.vcd
```

The waveform dump (`.vcd`) files are included in this repository to allow direct inspection of simulation results using GTKWave.

---

# Repository Structure

```
DFT-Sequential-Multiplier
│
├── README.md
├── LICENSE
├── .gitignore
├── multiplier_sim
│
├── rtl
│   ├── ICG.v
│   ├── bit_counter.v
│   ├── controller.v
│   ├── mult_regs.v
│   └── seq_multiplier.v
│
├── tb
│   └── tb_seq_multiplier_dft.v
│
└── vcd
    ├── seq_mult_dft.vcd
    └── multiplier_tb_gtk.vcd
```

---

# Project Highlights

- Functional 8-bit Sequential Multiplier
- Low-Power Clock Gating using Integrated Clock Gate (ICG)
- Clock Controllability for Manufacturing Test
- Complete 32-Bit Scan Chain Implementation
- Scan Shift and Capture Operations
- ATPG-Oriented DFT Architecture
- Functional and DFT Verification using Verilog
- Simulation Waveforms Included

---

# Learning Outcomes

This project demonstrates practical implementation of:

- Register Transfer Level (RTL) Design
- Finite State Machine (FSM) Design
- Datapath and Controller Integration
- Clock Gating for Low-Power Design
- Design for Testability (DFT)
- Clock Controllability
- Full Scan Chain Insertion
- Scan Shift and Capture Methodology
- At-Speed Testing Concepts
- ASIC Verification using Verilog HDL

---

# Future Improvements

Potential extensions include:

- Multiple Scan Chains
- Scan Compression
- IEEE 1149.1 Boundary Scan (JTAG)
- Automatic Test Pattern Generation (ATPG)
- Fault Simulation
- Synthesis using Synopsys Design Compiler
- Static Timing Analysis
- Scan Insertion using Commercial DFT Tools

---



ility, scan chain insertion, and DFT-aware verification in Verilog HDL.
