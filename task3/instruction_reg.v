module instruction_reg
(
    input        rst_i,
    input        clk_i,
    input        jump_i,
    input        branch_i,
    input [15:0] inst_i,

    output reg [15:0]   inst_o,
    output reg [7:0]    imm_o,
    output reg [7:0]    displacement_o,
    output reg [3:0]    addr_a_o,
    output reg [3:0]    addr_b_o
);

always @(posedge rst_i or posedge clk_i) begin
    // if reset, set all outputs to 0
    // if jump or branch, set inst_o to 0x0020, imm_o and displacement_o to 0x20, and addr_a_o and addr_b_o to 0
    // otherwise, set inst_o to inst_i, addr_a_o to bits [3:0] of inst_o, addr_b_o to bits [11:8] of inst_o, imm_o to bits [7:0] of inst_o, and displacement_o to bits [7:0] of inst_o
    if (rst_i) begin
        inst_o <= 16'b0;
        imm_o <= 8'b0;
        displacement_o <= 8'b0;
        addr_a_o <= 4'b0;
        addr_b_o <= 4'b0;

    end else if (jump_i || branch_i) begin
        inst_o <= 16'h0020;
        imm_o  <= 8'h20;
        displacement_o <= 8'h20;
        addr_a_o <= 4'h0;
        addr_b_o <= 4'h0;

    end else begin
        inst_o <= inst_i;
        addr_a_o <= inst_i[3:0];
        addr_b_o <= inst_i[11:8];
        imm_o <= inst_i[7:0];
        displacement_o <= inst_i[7:0];

    end
end

endmodule
