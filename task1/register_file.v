module register_file
(
    input           rst_i,
    input           clk_i,
    input           wr_i,
    input [15:0]    data_i,
    input [3:0]     addr_a_i,
    input [3:0]     addr_b_i,

    output reg [15:0] data_a_o,
    output reg [15:0] data_b_o
);

reg [15:0] reg0_r;
reg [15:0] reg1_r;
reg [15:0] reg2_r;
reg [15:0] reg3_r;
reg [15:0] reg4_r;
reg [15:0] reg5_r;
reg [15:0] reg6_r;
reg [15:0] reg7_r;
   
// TODO : implement the register file which has 8 registers and each register is 16-bit wide.
// Write data to the register file when wr_i is 1. The address of the register to write is given by addr_b_i.
// Read data from the register file when wr_i is 0. The address of the register to read is given by addr_a_i and addr_b_i, and the read data should be output to data_a_o and data_b_o, respectively.
always @(posedge rst_i or posedge clk_i) begin
    if (rst_i == 1'b1) begin
        reg0_r <= 16'h0;
        reg1_r <= 16'h0;
        reg2_r <= 16'h0;
        reg3_r <= 16'h0;
        reg4_r <= 16'h0;
        reg5_r <= 16'h0;
        reg6_r <= 16'h0;
        reg7_r <= 16'h0;
    end

    else begin
        if (wr_i == 1'b1) begin
            case (addr_b_i[2:0])
                3'b000: reg0_r <= data_i;
                3'b001: reg1_r <= data_i;
                3'b010: reg2_r <= data_i;
                3'b011: reg3_r <= data_i;
                3'b100: reg4_r <= data_i;
                3'b101: reg5_r <= data_i;
                3'b110: reg6_r <= data_i;
                3'b111: reg7_r <= data_i;
            endcase      
        end
    end
end


always @(*) begin
    data_a_o = 16'h0;
    data_b_o = 16'h0;

    case (addr_a_i[2:0])
        3'b000: data_a_o = reg0_r;
        3'b001: data_a_o = reg1_r;
        3'b010: data_a_o = reg2_r;
        3'b011: data_a_o = reg3_r;
        3'b100: data_a_o = reg4_r;
        3'b101: data_a_o = reg5_r;
        3'b110: data_a_o = reg6_r;
        3'b111: data_a_o = reg7_r;
    endcase

    case (addr_b_i[2:0])
        3'b000: data_b_o = reg0_r;
        3'b001: data_b_o = reg1_r;
        3'b010: data_b_o = reg2_r;
        3'b011: data_b_o = reg3_r;
        3'b100: data_b_o = reg4_r;
        3'b101: data_b_o = reg5_r;
        3'b110: data_b_o = reg6_r;
        3'b111: data_b_o = reg7_r;
    endcase
end

endmodule
