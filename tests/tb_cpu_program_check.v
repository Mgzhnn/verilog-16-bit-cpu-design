`timescale 1ns/1ns

// Runs task4/imem_img and checks its architectural result.
// The program sets r0 = 0xFFFF, r1 = 0x0100, r2 = 0x01FF, then loops:
// CMP r1, r2; if r1 != r2 jump to the store; STOR r0, [r1]; ADDI r1, 1; jump back.
// When r1 reaches r2 it resets r1 to r5 (0x0100) and starts over, so one pass
// writes 0xFFFF to 0x0100..0x01FE (0x01FF itself is compared, never stored).
module tb_cpu_program_check;

cpu_harness #(.PROGRAM("task4/imem_img")) h();

integer a, errors;

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
    #40000;  // more than one full pass of the loop

    for (a = 16'h0100; a <= 16'h01FE; a = a + 1) begin
        if (h.u_dmem.my_memory[a] !== 16'hFFFF) begin
            errors = errors + 1;
            if (errors <= 5) $display("dmem[%h] = %h, want ffff", a, h.u_dmem.my_memory[a]);
        end
    end
    if (h.u_dmem.my_memory[16'h00FF] !== 16'h0000 || h.u_dmem.my_memory[16'h01FF] !== 16'h0000) begin
        errors = errors + 1;
        $display("dmem outside 0x0100..0x01FE was written");
    end

    expect_reg(0, h.u_proc.rf_ready.reg0_r, 16'hFFFF);
    expect_reg(2, h.u_proc.rf_ready.reg2_r, 16'h01FF);
    expect_reg(3, h.u_proc.rf_ready.reg3_r, 16'h0012);
    expect_reg(4, h.u_proc.rf_ready.reg4_r, 16'h000F);
    expect_reg(5, h.u_proc.rf_ready.reg5_r, 16'h0100);

    if (errors == 0) $display("PASS tb_cpu_program_check: dmem 0x0100..0x01FE = 0xFFFF, registers as expected");
    else             $display("FAIL tb_cpu_program_check: %0d mismatches", errors);
    $finish;
end

endmodule
