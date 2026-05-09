`timescale 1ns/1ns

module test_alu;

`include "ALU_modes.vh"

reg [15:0]  data_a;
reg [15:0]  data_b;
reg [5:0]   alu_sel;
reg         clk;
reg         rst;

wire [4:0]  flags_w;
wire [4:0]  flags_o;
wire [15:0] alu_w;

initial begin: gen_clock200MHz
    clk = 1'b1;
    forever begin
        #5
        clk = !clk;
    end
end

initial begin: gen_reset
    rst = 1'b0;
    #5 rst = 1'b1;
    #10 rst = 1'b0;
end

initial begin
    alu_sel <= ALU_SEL_ADD;
    data_a <= 16'hDEAD;
    data_b <= 16'hCAFE;

    /* Test pair 1 */
    @(negedge rst);
    @(posedge clk);
    
    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

    /* Test pair 2 */
    @(posedge clk);
    data_a <= 16'h10AF;
    data_b <= 16'hBEEF;
    alu_sel <= ALU_SEL_ADD;

    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

    /* Test pair 3 */
    @(posedge clk);
    data_a <= 16'hBAAD;
    data_b <= 16'hC0DE;
    alu_sel <= ALU_SEL_ADD;

    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

    /* Test pair 4 */
    @(posedge clk);
    data_a <= 16'h0003;
    data_b <= 16'h0004;
    alu_sel <= ALU_SEL_ADD;

    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

    /* Test pair 5 */
    @(posedge clk);
    data_a <= 16'h4B1D;
    data_b <= 16'h10AF;
    alu_sel <= ALU_SEL_ADD;

    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

    /* Test pair 6 */
    @(posedge clk);
    data_a <= 16'h5440;
    data_b <= 16'hABBA;
    alu_sel <= ALU_SEL_ADD;

    @(posedge clk);
    alu_sel <= ALU_SEL_SUB;

    @(posedge clk);
    alu_sel <= ALU_SEL_CMP;

    @(posedge clk);
    alu_sel <= ALU_SEL_AND;

    @(posedge clk);
    alu_sel <= ALU_SEL_OR;

    @(posedge clk);
    alu_sel <= ALU_SEL_XOR;

end

alu u_alu(
    .A_i(data_a),
    .B_i(data_b),
    .alu_sel_i(alu_sel),

    .flags_o(flags_w),
    .alu_o(alu_w)
);

psr u_psr(
    .rst_i(rst),
    .clk_i(clk),
    .alu_sel_i(alu_sel),
    .flags_i(flags_w),

    .flags_o(flags_o)
);

endmodule
