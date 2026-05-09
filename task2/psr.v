/*
 * Program status register
 * FLCNZ for each bit [4:0]
 */

module psr
(
    input       rst_i,
    input       clk_i,
    input [5:0] alu_sel_i,
    input [4:0] flags_i,        //FLCNZ
    
    output reg [4:0] flags_o    //selected FLCNZ
);

`include "ALU_modes.vh"


always @(posedge rst_i or posedge clk_i) begin
    if (rst_i == 1'b1)
        flags_o <= 0;
        
    else begin
        // for add and sub, only update F and C flags
        // L, N, Z stay the same
        if (alu_sel_i == ALU_SEL_ADD || alu_sel_i == ALU_SEL_SUB) begin
            flags_o[4] <= flags_i[4]; // F
            flags_o[2] <= flags_i[2]; // C
        end

        // for cmp, only update L, N, Z
        // F and C stay the same
        else if (alu_sel_i == ALU_SEL_CMP) begin
            flags_o[3] <= flags_i[3]; // L
            flags_o[1] <= flags_i[1]; // N
            flags_o[0] <= flags_i[0]; // Z
            // for everything else (AND, OR, XOR) dont change anything
        end       
    end
end

endmodule

