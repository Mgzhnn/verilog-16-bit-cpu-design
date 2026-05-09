# CPU Design Project

Verilog CPU design project organized by task folders. The final top-level simulation is in `task4` and uses modules from `task1`, `task2`, and `task3`.

## Project Structure

- `task1/` - register file and testbench
- `task2/` - ALU, carry lookahead adder, shifter, PSR, and ALU mode header
- `task3/` - program counter, decoder, instruction register, and opcode header
- `task4/` - top processor, memory files, multiplexers, buffers, and final testbench
- `202411179_MagzhanZiyabek_report.pdf` - project report
- `Project Tasks.pdf` - assignment description

## How to Run the Simulations in ModelSim

The simulation flow below was verified in ModelSim. Run these commands in the ModelSim TCL console in this order:

```tcl
cd "<full path to task4 folder>"
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

The `+incdir+` flags are required so ModelSim can find the `.vh` header files in `task2` and `task3`.

Run the `cd` command first so `block_ram.v` can open `imem_img`. Add waves before `run -all`; otherwise, signals may not be recorded in the waveform.

## Possible Errors and Fixes

### `decoder.v` fails with `Cannot open ALU_modes.vh`

Use the `vlog` command shown above because it includes `+incdir+../task2`. If compiling another way still causes this error, replace the ``include "ALU_modes.vh"`` line in `decoder.v`, `alu.v`, and `psr.v` with the six `ALU_SEL_*` parameter definitions directly inside each file.

### `Failed to open file imem_img for reading`

ModelSim is not running from the `task4` directory. Run:

```tcl
cd "<full path to task4 folder>"
```

before calling `vsim`.

### `.vh files give "Global declarations are illegal"`

The `.vh` files were accidentally added to the project compile list. Remove `ALU_modes.vh` and `opcodes.vh` from the file list and recompile.

### Warning: `Expected a system task, not $fscanf`

This is a ModelSim version compatibility warning and can be safely ignored. The simulation still runs correctly.
