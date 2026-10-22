`timescale 1ns/1ns

// Self-checking register file test: reset clears all registers, writes land in the
// register addressed by addr_b, both read ports return it, wr=0 leaves registers
// unchanged, and address bit 3 is ignored (r8..r15 map onto r0..r7).
module tb_register_file_check;

reg         clk, rst, wr;
reg  [15:0] wdata;
reg  [3:0]  addr_a, addr_b;
wire [15:0] dout_a, dout_b;

register_file u_rf(
    .rst_i(rst),
    .clk_i(clk),
    .wr_i(wr),
    .data_i(wdata),
    .addr_a_i(addr_a),
    .addr_b_i(addr_b),
    .data_a_o(dout_a),
    .data_b_o(dout_b)
);

initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
end

integer r, errors;

task check(input [3:0] a, input [3:0] b, input [15:0] want_a, input [15:0] want_b);
    begin
        addr_a = a;
        addr_b = b;
        #1;
        if (dout_a !== want_a || dout_b !== want_b) begin
            errors = errors + 1;
            $display("read r%0d/r%0d: got %h/%h want %h/%h", a, b, dout_a, dout_b, want_a, want_b);
        end
    end
endtask

initial begin
    errors = 0;
    wr = 1'b0; wdata = 0; addr_a = 0; addr_b = 0;
    rst = 1'b1; #12 rst = 1'b0;

    for (r = 0; r < 8; r = r + 1) check(r, 7 - r, 16'h0000, 16'h0000);

    // Write a distinct value to each register through port B
    for (r = 0; r < 8; r = r + 1) begin
        @(negedge clk);
        wr = 1'b1; addr_b = r; wdata = 16'hA000 + r;
        @(posedge clk); #1;
    end
    @(negedge clk) wr = 1'b0;

    for (r = 0; r < 8; r = r + 1) check(r, r, 16'hA000 + r, 16'hA000 + r);
    for (r = 8; r < 16; r = r + 1) check(r, r, 16'hA000 + r - 8, 16'hA000 + r - 8);

    // wr = 0 must not write
    @(negedge clk);
    addr_b = 3; wdata = 16'hDEAD;
    @(posedge clk); #1;
    check(3, 3, 16'hA003, 16'hA003);

    if (errors == 0) $display("PASS tb_register_file_check");
    else             $display("FAIL tb_register_file_check: %0d mismatches", errors);
    $finish;
end

endmodule
