# Full Adder RTL-to-GDSII Top-Down VLSI Flow

This project demonstrates a complete professional top-down digital VLSI workflow. It goes beyond a simple Verilog implementation by incorporating area/power optimization, cross-verification against a C golden model, and preparation for physical ASIC layout (Place & Route, DRC, LVS).

## Directory Structure
*   `src/` - Contains the unoptimized and optimized Verilog RTL.
*   `sim/` - Contains the SystemVerilog testbench and the expected output text file.
*   `c_model/` - Contains the C program used to generate the golden truth table reference.
*   `openlane/` - Contains configurations for the OpenLane ASIC physical design flow.

## 1. Architecture and Hardware Optimization
The initial implementation of the full adder relied on naive boolean logic:
*   `Sum = A ^ B ^ Cin`
*   `Cout = (A & B) | (B & Cin) | (A & Cin)`

To minimize gate count (Area) and reduce switching activity (Power), the hardware was restructured in `full_adder_opt.v` using a half-adder resource sharing approach:
*   **Propagate (P)** = `A ^ B`
*   **Generate (G)** = `A & B`
*   **Optimized Sum** = `P ^ Cin`
*   **Optimized Cout** = `G | (P & Cin)`

This optimization reuses the `P` state for both the Sum and Cout evaluations, minimizing standard cell requirements during synthesis.

## 2. Verification Methodology
To ensure robust verification, a cross-language methodology was utilized rather than visual waveform inspection alone:
1.  **C Golden Model**: A C program (`full_adder_model.c`) computes the mathematically perfect outputs for all combinations and dumps them to `expected_outputs.txt`.
2.  **SystemVerilog Automation**: The testbench (`tb_full_adder.sv`) uses `$fscanf` to read the C-model's golden text file line-by-line. It drives the Verilog DUT (Device Under Test) with the expected inputs, and automatically asserts the Verilog hardware outputs against the C-model outputs, logging PASS/FAIL checks to the console.

## 3. Physical Design / ASIC Flow (OpenLane)
The project includes ready-to-run configurations for **OpenLane**, the open-source RTL-to-GDSII ASIC orchestration tool targeting the Skywater 130nm PDK.

The `openlane/config.json` isolates the design environment:
*   Clock tree synthesis is explicitly disabled (combinational logic).
*   Die area constraint is tightly packed to 40x40 μm.
*   `pin_order.cfg` enforces logic-flow aesthetic physical pin placements (West -> East).

Running `./flow.tcl -design full_adder` in OpenLane will automatically execute:
*   **Yosys**: Logic Synthesis mapping RTL to Sky130 standard cells.
*   **OpenROAD**: Floorplanning, Placement, and Routing.
*   **Magic**: Design Rule Check (DRC) and physical GDSII layout visualization.
*   **Netgen**: Layout vs Schematic (LVS) electrical equivalence checking.
