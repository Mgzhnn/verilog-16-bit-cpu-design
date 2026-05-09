# Verilog 16-bit CPU Design

A 16-bit CPU design written in Verilog and verified with ModelSim simulations. The project is organized as a set of incremental hardware design tasks that build toward the final top-level processor in `task4`.

## Overview

This project implements the main datapath and control blocks for a simple 16-bit processor:

- 8-register, 16-bit register file
- 16-bit carry lookahead adder built from 4-bit CLA blocks and a lookahead carry unit
- ALU operations for arithmetic, comparison, and bitwise logic
- Processor status register with `F`, `L`, `C`, `N`, and `Z` flags
- Shifter and load-upper-immediate support
- Program counter, instruction register, and instruction decoder
- Top-level processor integration with instruction and data memory interfaces

## Repository Structure

```text
.
|-- task1/
|   |-- register_file.v
|   `-- test_register_file.v
|-- task2/
|   |-- alu.v
|   |-- cla4.v
|   |-- cla16.v
|   |-- lcu4.v
|   |-- psr.v
|   |-- shifter.v
|   |-- ALU_modes.vh
|   |-- test_alu.v
|   `-- test_shifter.v
|-- task3/
|   |-- decoder.v
|   |-- instruction_reg.v
|   |-- pc.v
|   |-- opcodes.vh
|   `-- test_fetch.v
`-- task4/
    |-- top_processor.v
    |-- block_ram.v
    |-- mux16_2to1.v
    |-- mux5_2to1.v
    |-- tristate_buf16.v
    |-- imem_img
    |-- dmem_img
    `-- test_top.v
```

## Main Modules

| Module | Description |
| --- | --- |
| `register_file.v` | 8-entry register file with two read ports and one write port |
| `cla4.v`, `lcu4.v`, `cla16.v` | Hierarchical carry lookahead adder implementation |
| `alu.v` | 16-bit ALU with arithmetic, comparison, and logic operations |
| `psr.v` | Processor status register for ALU flags |
| `shifter.v` | Shift and load-upper-immediate datapath block |
| `pc.v` | Program counter with branch and jump support |
| `instruction_reg.v` | Instruction register and field extraction |
| `decoder.v` | Control signal generation from opcode and flags |
| `top_processor.v` | Integrated top-level CPU datapath |

## Running the Final Simulation

The final integrated simulation is in `task4`. Run the following commands in the ModelSim TCL console:

```tcl
cd "<full path to this repository>/task4"
vlib work
vlog +incdir+../task2 +incdir+../task3 \
  ../task1/register_file.v \
  ../task2/cla4.v ../task2/lcu4.v ../task2/cla16.v \
  ../task2/shifter.v ../task2/alu.v ../task2/psr.v \
  ../task3/decoder.v ../task3/pc.v ../task3/instruction_reg.v \
  block_ram.v mux16_2to1.v mux5_2to1.v tristate_buf16.v \
  top_processor.v test_top.v
vsim work.test_top
add wave sim:/test_top/*
restart
run -all
```

The `+incdir+../task2` and `+incdir+../task3` flags are required so ModelSim can find `ALU_modes.vh` and `opcodes.vh`.

Run the `cd` command before compiling or simulating. The memory loader in `block_ram.v` expects `imem_img` to be available from the `task4` working directory.

## Running Individual Testbenches

The project also includes smaller testbenches for individual components:

- `task1/test_register_file.v`
- `task2/test_alu.v`
- `task2/test_shifter.v`
- `task3/test_fetch.v`

Compile each testbench with the modules it depends on. For files that include `.vh` headers, keep the same `+incdir+` style used in the final simulation command.

## Troubleshooting

### `Cannot open ALU_modes.vh`

Add `+incdir+../task2` to the `vlog` command.

### `Cannot open opcodes.vh`

Add `+incdir+../task3` to the `vlog` command.

### `Failed to open file imem_img for reading`

Start ModelSim from the `task4` directory:

```tcl
cd "<full path to this repository>/task4"
```

### `.vh files give "Global declarations are illegal"`

Do not compile the `.vh` files as standalone Verilog files. They are header files included by other modules.

### Warning: `Expected a system task, not $fscanf`

This is a ModelSim compatibility warning and does not prevent the simulation from running.

## Author

Magzhan Ziyabek
