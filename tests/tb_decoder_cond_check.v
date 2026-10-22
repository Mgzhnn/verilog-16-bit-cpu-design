`timescale 1ns/1ns

// Self-checking condition test: for all 16 condition codes and all 32 PSR flag
// combinations, Jcond (JMP) and Bcond (BR) must follow the CR16 condition table.
module tb_decoder_cond_check;

reg  [15:0] inst;
reg  [4:0]  psr;   // F, L, C, N, Z
wire        jmp, br;

decoder u_dec(
    .inst_i(inst),
    .psr_flags_i(psr),
    .TRI_SEL(),
    .ALU_SEL(),
    .WR(),
    .JMP(jmp),
    .BR(br),
    .IMM_EX_SEL(),
    .MUX_SEL0(),
    .MUX_SEL1(),
    .SHIFT_IMM(),
    .LUI(),
    .WE()
);

// CR16 condition codes
function cond_true(input [3:0] c, input [4:0] f);
    reg F, L, C, N, Z;
    begin
        {F, L, C, N, Z} = f;
        case (c)
            4'h0: cond_true = Z;             // EQ
            4'h1: cond_true = !Z;            // NE
            4'h2: cond_true = C;             // CS
            4'h3: cond_true = !C;            // CC
            4'h4: cond_true = L;             // HI
            4'h5: cond_true = !L;            // LS
            4'h6: cond_true = N;             // GT
            4'h7: cond_true = !N;            // LE
            4'h8: cond_true = F;             // FS
            4'h9: cond_true = !F;            // FC
            4'hA: cond_true = !L && !Z;      // LO
            4'hB: cond_true = L || Z;        // HS
            4'hC: cond_true = !N && !Z;      // LT
            4'hD: cond_true = N || Z;        // GE
            4'hE: cond_true = 1'b1;          // UC
            default: cond_true = 1'b0;       // never
        endcase
    end
endfunction

integer c, f, errors;

initial begin
    errors = 0;
    for (c = 0; c < 16; c = c + 1) begin
        for (f = 0; f < 32; f = f + 1) begin
            psr = f;
            inst = {4'b0100, c[3:0], 4'b1100, 4'h3};  // Jcond r3
            #1;
            if (jmp !== cond_true(c, f) || br !== 1'b0) begin
                errors = errors + 1;
                $display("Jcond cond=%h flags=%b: JMP=%b BR=%b", c, f[4:0], jmp, br);
            end
            inst = {4'b1100, c[3:0], 8'hFD};          // Bcond -3
            #1;
            if (br !== cond_true(c, f) || jmp !== 1'b0) begin
                errors = errors + 1;
                $display("Bcond cond=%h flags=%b: BR=%b JMP=%b", c, f[4:0], br, jmp);
            end
        end
    end

    if (errors == 0) $display("PASS tb_decoder_cond_check: 16 conditions x 32 flag values, Jcond and Bcond");
    else             $display("FAIL tb_decoder_cond_check: %0d mismatches", errors);
    $finish;
end

endmodule
