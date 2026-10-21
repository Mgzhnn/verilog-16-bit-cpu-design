#!/usr/bin/env bash
# Run every self-checking testbench with Icarus Verilog (iverilog + vvp).
# Usage, from anywhere:  tests/run_tests.sh
# Set IVERILOG / VVP to use binaries that are not on PATH.
set -u

cd "$(dirname "$0")/.."
IVERILOG="${IVERILOG:-iverilog}"
VVP="${VVP:-vvp}"
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT

RTL_ALU="task2/cla4.v task2/lcu4.v task2/cla16.v task2/alu.v"
RTL_CPU="task1/register_file.v $RTL_ALU task2/shifter.v task2/psr.v
         task3/decoder.v task3/pc.v task3/instruction_reg.v
         task4/block_ram.v task4/mux16_2to1.v task4/mux5_2to1.v task4/tristate_buf16.v
         task4/top_processor.v tests/cpu_harness.v"

run() {
    local top="$1"; shift
    if ! "$IVERILOG" -g2005 -I task2 -I task3 -s "$top" -o "$BUILD/$top.vvp" "$@" tests/"$top".v; then
        echo "FAIL $top: compile error"
        return 1
    fi
    local out
    out="$("$VVP" "$BUILD/$top.vvp")"
    echo "$out" | grep -E "^(PASS|FAIL)|^[a-z]" | grep -v "finish called"
    echo "$out" | grep -q "^PASS $top"
}

failed=0
run tb_alu_check            $RTL_ALU                || failed=$((failed + 1))
run tb_shifter_check        task2/shifter.v         || failed=$((failed + 1))
run tb_register_file_check  task1/register_file.v   || failed=$((failed + 1))
run tb_decoder_cond_check   task3/decoder.v         || failed=$((failed + 1))
run tb_cpu_program_check    $RTL_CPU                || failed=$((failed + 1))
run tb_cpu_control_check    $RTL_CPU                || failed=$((failed + 1))

if [ "$failed" -eq 0 ]; then
    echo "All tests passed"
else
    echo "$failed test(s) failed"
    exit 1
fi
