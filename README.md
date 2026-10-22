# Verilog 16-bit CPU Design

A 16-bit CPU design written in Verilog, simulated in ModelSim and checked by self-checking testbenches (Icarus Verilog). The project is organized as a set of incremental hardware design tasks that build toward the final top-level processor in `task4`.

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
`-- tests/
    |-- run_tests.sh
    |-- cpu_harness.v
    |-- control_imem
    `-- tb_*_check.v
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

Run the `cd` command before compiling or simulating. The memory loader in `block_ram.v` reads `imem_img` (one 16-bit binary word per line, any number of lines) from the `task4` working directory and fills the rest of instruction memory with NOPs.

## Running the Self-Checking Tests

`tests/` holds testbenches that compare the design against independent references and print `PASS` or `FAIL`. Run them all with [Icarus Verilog](https://steveicarus.github.io/iverilog/):

```bash
tests/run_tests.sh
```

| Test | Checks |
| --- | --- |
| `tb_alu_check` | 120,000 operations: all six ALU operations and the F/C (ADD, SUB) and L/N/Z (CMP) flags |
| `tb_shifter_check` | Every shift amount from -16 to 15, and LUI |
| `tb_register_file_check` | Reset, writes, both read ports, no write when `wr_i` is 0, r8–r15 aliasing |
| `tb_decoder_cond_check` | All 16 condition codes against all 32 flag values, for Jcond and Bcond |
| `tb_cpu_program_check` | Runs `task4/imem_img` and checks data memory and registers |
| `tb_cpu_control_check` | Runs `tests/control_imem`: taken and not-taken branches, JAL, flush NOPs |

The script exits with status 1 if any test fails. Set `IVERILOG` and `VVP` to use binaries that are not on `PATH`.

## Design Notes

- **Two stages.** The instruction register holds the instruction being executed while the next one is fetched. A taken jump or branch replaces the fetched instruction with a NOP (`0x0020`, `OR r0, r0`).
- **Branch target.** The displacement is added to the address of the instruction after the branch: target = branch address + 1 + displacement. (CR16 adds it to the branch's own address.)
- **JAL** saves the address of the instruction after the JAL.
- **Registers.** Instructions have 4-bit register fields, but the register file uses only bits [2:0], so r8–r15 map onto r0–r7.
- **`imem_img` program.** It sets r0 = 0xFFFF, r1 = 0x0100 and r2 = 0x01FF, then loops: compare r1 with r2, store r0 at address r1, increment r1. One pass writes 0xFFFF to 0x0100–0x01FE; when r1 reaches 0x01FF the loop restarts from 0x0100 without storing to 0x01FF.

## Running Individual Testbenches

The project also includes smaller testbenches for individual components:

- `task1/test_register_file.v`
- `task2/test_alu.v`
- `task2/test_shifter.v`
- `task3/test_fetch.v`

These drive inputs for waveform inspection and do not check results; the self-checking versions are in `tests/`. Compile each testbench with the modules it depends on. For files that include `.vh` headers, keep the same `+incdir+` style used in the final simulation command.

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

## Author

Magzhan Ziyabek
