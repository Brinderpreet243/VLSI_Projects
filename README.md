# VLSI Projects

A collection of digital VLSI design projects covering the complete RTL-to-GDSII top-down design methodology. Each project demonstrates synthesizable Verilog/SystemVerilog design, cross-verification against C golden models, and preparation for ASIC physical layout using the open-source OpenLane flow (Skywater 130nm PDK).

## Projects

| # | Project | Description | Status |
|---|---------|-------------|--------|
| 1 | [Full Adder ASIC Flow](./Full_Adder_ASIC_Flow) | Optimized 1-bit Full Adder with complete RTL-to-GDSII flow | Done |

## Tools Used
- **RTL Design**: Verilog, SystemVerilog
- **Simulation**: Xilinx Vivado 2024.2 (xvlog, xelab, xsim)
- **Verification**: C modeling, automated testbench assertions via File I/O
- **ASIC Physical Design**: OpenLane (Yosys, OpenROAD, Magic, Netgen)
- **Target PDK**: Skywater 130nm (sky130A)

## Project Template
Each project follows a consistent directory structure:
```
Project_Name/
├── src/          # Synthesizable RTL (Verilog)
├── sim/          # Testbenches (SystemVerilog) and expected outputs
├── c_model/      # C golden reference model
├── openlane/     # OpenLane ASIC flow configuration
└── README.md     # Project-specific documentation
```
