`timescale 1ns/1ns

// Runs tests/control_imem, which exercises taken and not-taken branches, JAL and
// the NOP inserted after a taken jump or branch.
//
//  0  MOVI r1, 1
//  1  BUC  +2          taken: lands on 4 (see below), skipping 2 and 3
//  2  MOVI r2, 2       skipped
//  3  MOVI r3, 3       skipped
//  4  MOVI r4, 4
//  5  MOVI r5, 5
//  6  MOVI r6, 10
//  7  JAL  r7, r6      r7 = 8, jump to 10
//  8  MOVI r1, 0x88    skipped
//  9  NOP
// 10  CMP  r4, r5      not equal
// 11  BEQ  +2          not taken
// 12  MOVI r2, 0x22    runs
// 13  CMP  r4, r4      equal
// 14  BEQ  +2          taken: lands on 17
// 15  MOVI r3, 0x33    skipped
// 16  MOVI r3, 0x44    skipped
// 17  MOVI r6, 0x66    runs
// 18  BUC  -1          loops on itself
//
// Branch target: this design adds the displacement to the address of the
// instruction after the branch (branch address + 1 + displacement). CR16 adds it
// to the branch's own address; if the processor is changed to that convention,
// the expected values below change (r3 = 3 after the first branch, and so on).
module tb_cpu_control_check;

cpu_harness #(.PROGRAM("tests/control_imem")) h();

integer errors;

task expect_reg(input [2:0] r, input [15:0] got, input [15:0] want);
    begin
        if (got !== want) begin
            errors = errors + 1;
            $display("r%0d = %h, want %h", r, got, want);
        end
    end
endtask

initial begin
    errors = 0;
    #500;

    expect_reg(1, h.u_proc.rf_ready.reg1_r, 16'h0001);  // instruction skipped by JAL did not run
    expect_reg(2, h.u_proc.rf_ready.reg2_r, 16'h0022);  // not-taken BEQ fell through
    expect_reg(3, h.u_proc.rf_ready.reg3_r, 16'h0000);  // both skipped regions skipped
    expect_reg(4, h.u_proc.rf_ready.reg4_r, 16'h0004);
    expect_reg(5, h.u_proc.rf_ready.reg5_r, 16'h0005);
    expect_reg(6, h.u_proc.rf_ready.reg6_r, 16'h0066);  // taken BEQ landed on 17
    expect_reg(7, h.u_proc.rf_ready.reg7_r, 16'h0008);  // JAL return address

    if (errors == 0) $display("PASS tb_cpu_control_check: branches, JAL and flush NOPs");
    else             $display("FAIL tb_cpu_control_check: %0d mismatches", errors);
    $finish;
end

endmodule
