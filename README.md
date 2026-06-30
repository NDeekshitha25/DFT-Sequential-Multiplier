# DFT-Aware Sequential Shift-and-Add Multiplier

An 8-bit Sequential Shift-and-Add Multiplier implemented in Verilog with **Design for Testability (DFT)** enhancements, including **Integrated Clock Gating (ICG)**, **clock controllability**, **full scan chain insertion**, and a **DFT-aware verification testbench**.

---

## Overview

This project extends a conventional sequential multiplier by incorporating industry-standard DFT techniques used in ASIC design. The implementation demonstrates how functional RTL can be modified to improve testability while preserving functional behavior and reducing dynamic power through clock gating.

### Key Features

* 8-bit Sequential Shift-and-Add Multiplier
* FSM-based Controller
* Integrated Clock Gating (ICG)
* Test Mode Clock Gate Bypass
* Full 32-bit Scan Chain
* Scan Shift and Capture Operations
* At-Speed Capture Support
* DFT-Aware RTL Design
* Comprehensive Verification Testbench

---

## Design Architecture

The design consists of the following modules:

```
rtl/
├── ICG.v
├── bit_counter.v
├── controller.v
├── mult_regs.v
└── seq_multiplier.v
```

### Module Description

| Module             | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| `ICG.v`            | Integrated Clock Gate with test bypass                              |
| `controller.v`     | FSM controlling multiplier operations                               |
| `mult_regs.v`      | Registers for Accumulator (A), Multiplicand (M), and Multiplier (Q) |
| `bit_counter.v`    | Clock-gated counter with scan support                               |
| `seq_multiplier.v` | Top-level integration of datapath, controller, and scan chain       |

---

## DFT Enhancements

### Clock Controllability

The original clock-gated counter prevented scan operations when `count_en` was low.

The solution introduces an **Integrated Clock Gate (ICG)** with a **test_mode** input that bypasses functional clock gating during manufacturing test.

```
Functional Mode:
clk ──► ICG(enable=count_en) ──► Counter

Test Mode:
clk ──► ICG(test_enable=1) ──► Counter
```

---

### Scan Chain

A full scan chain is inserted across all sequential elements.

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

## Scan Operation

### Functional Mode

```
test_mode  = 0
scan_enable = 0
```

* Clock gating enabled
* Normal multiplication
* Low-power operation

---

### Scan Shift Mode

```
test_mode  = 1
scan_enable = 1
```

* Clock gate bypassed
* Registers load scan data
* Full scan controllability

---

### Capture Mode

```
test_mode  = 1
scan_enable = 0
```

* Clock gate bypassed
* One functional clock applied
* Functional response captured for ATPG

---

## Verification

The DFT-aware testbench verifies both functional correctness and scan functionality.

### Test Cases

### Test C1 – Functional Verification

* 13 × 11 multiplication
* Product verified as **143**
* Clock gating behavior monitored
* Power savings measured using gated clock activity

---

### Test C2 – Scan Shift Test

* Shift 32-bit scan pattern
* Verify all registers receive correct values
* Confirm scan works even when `count_en = 0`

---

### Test C3 – Shift–Capture–Shift

* Shift ATPG pattern
* Apply one capture clock
* Shift captured response out
* Compare against expected response

---

### Test C4 – At-Speed Capture

* Load counter through scan chain
* Apply one functional clock
* Verify counter increment
* Verify `last` assertion
* Demonstrate identical timing in functional and test modes

---

## Simulation

### Compile (Icarus Verilog)

```bash
iverilog -o sim rtl/*.v tb/tb_seq_multiplier_dft.v
```

### Run

```bash
vvp sim
```

### View Waveforms

```bash
gtkwave seq_mult_dft.vcd
```

---

## Repository Structure

```
DFT-Sequential-Multiplier
│
├── README.md
├── .gitignore
│
|-- multiplier_sim
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
    ├── multiplier_tb_gtk.vcd
```

---

## Learning Outcomes

This project demonstrates practical implementation of:

* Register Transfer Level (RTL) Design
* Finite State Machine (FSM) Design
* Design for Testability (DFT)
* Full Scan Chain Insertion
* Clock Controllability
* Integrated Clock Gating (ICG)
* Scan Shift and Capture Operations
* ATPG-Oriented Verification
* Digital ASIC Verification using Verilog

---

## Future Improvements

* Scan compression support
* Boundary Scan (IEEE 1149.1/JTAG)
* Multiple scan chains
* Automatic Test Pattern Generation (ATPG)
* Fault simulation
* Synthesis and timing analysis using industry EDA tools




