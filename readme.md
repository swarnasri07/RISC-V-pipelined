# 32-bit Pipelined RISC-V Processor (RV32I)

* Status: Fully functional and hardware-verified
* Architecture: RV32I base integer instruction set
* Implementation: Verilog HDL (built entirely from scratch)

## Core Features
* 5-Stage Pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), Write Back (WB)
* Instruction Support: 37 total instructions mapped and verified
* Hardware Verification: Deployed on Digilent Basys3 FPGA computing Fibonacci sequence in real-time via a 7-segment display

## Advanced Hazard Control
* Data Forwarding: Bypasses MEM/WB results directly to EX stage to resolve RAW hazards
* Branch Hazard Mitigation: Stalls until MEM/WB is ready, forwards to ID for comparison, flushes incorrect paths for minimal penalty
* Load-Use Stall: Dynamic pipeline bubble insertion for load-dependent sequences
* Store Forwarding: Resolves dependencies for stores relying on recently computed ALU values

## Instruction Set Architecture (37 Supported)
| Category | Instructions |
| :--- | :--- |
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| Load | LW, LH, LB, LHU, LBU |
| Store | SW, SH, SB |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| U-type | LUI, AUIPC |

## Run Simulation

```bash
iverilog -o cpu.out *.v
vvp cpu.out
gtkwave cpu.vcd
```

## Tech Tools
* Verilog HDL
* Xilinx Vivado (Synthesis and Implementation)
* GTKWave (Waveform Analysis)
* FPGA Basys3 board

## Author
* Bhamidipati Swarna Sri
* Electronics and Communication Engineering, IIT Bhubaneswar

---
