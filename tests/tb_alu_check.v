`timescale 1ns/1ns

// Self-checking ALU test: random and corner-case operands for every operation,
// compared with a behavioural reference. Flags checked are the ones the PSR keeps:
// F and C for ADD/SUB, L, N and Z for CMP. SUB and CMP compute B - A (Rdest - Rsrc).
module tb_alu_check;

`include "ALU_modes.vh"

reg  [15:0] A, B;
reg  [5:0]  sel;
wire [4:0]  flags;  // F, L, C, N, Z
wire [15:0] y;

alu u_alu(
    .A_i(A),
    .B_i(B),
    .alu_sel_i(sel),
    .flags_o(flags),
    .alu_o(y)
);

reg [16:0] wide;
reg [15:0] want_y;
reg want_f, want_c;
integer n, op, errors;

initial begin
    errors = 0;
    for (n = 0; n < 20000; n = n + 1) begin
        A = $random;
        B = $random;
        if (n < 16) begin            // corner cases: 0000/FFFF and near-equal operands
            A = {16{n[0]}};
            B = {16{n[1]}} ^ n;
        end
        for (op = 0; op < 6; op = op + 1) begin
            sel = 6'b100000 >> op;   // ADD, SUB, CMP, AND, OR, XOR
            #1;
            case (sel)
                ALU_SEL_ADD: begin
                    wide = B + A;
                    want_y = wide[15:0];
                    want_c = wide[16];
                    want_f = (A[15] == B[15]) && (want_y[15] != A[15]);
                end
                ALU_SEL_SUB, ALU_SEL_CMP: begin
                    want_y = B - A;
                    want_c = (B < A);  // borrow
                    want_f = (A[15] != B[15]) && (want_y[15] != B[15]);
                end
                ALU_SEL_AND: want_y = A & B;
                ALU_SEL_OR:  want_y = A | B;
                default:     want_y = A ^ B;
            endcase

            if (y !== want_y) begin
                errors = errors + 1;
                if (errors <= 5) $display("result: sel=%b A=%h B=%h got %h want %h", sel, A, B, y, want_y);
            end
            if ((sel == ALU_SEL_ADD || sel == ALU_SEL_SUB) && (flags[4] !== want_f || flags[2] !== want_c)) begin
                errors = errors + 1;
                if (errors <= 5) $display("F/C: sel=%b A=%h B=%h got F=%b C=%b want F=%b C=%b", sel, A, B, flags[4], flags[2], want_f, want_c);
            end
            if (sel == ALU_SEL_CMP && (flags[3] !== (B < A) || flags[1] !== ($signed(B) < $signed(A)) || flags[0] !== (B == A))) begin
                errors = errors + 1;
                if (errors <= 5) $display("L/N/Z: A=%h B=%h got %b%b%b", A, B, flags[3], flags[1], flags[0]);
            end
        end
    end

    if (errors == 0) $display("PASS tb_alu_check: 120000 operations");
    else             $display("FAIL tb_alu_check: %0d mismatches", errors);
    $finish;
end

endmodule
