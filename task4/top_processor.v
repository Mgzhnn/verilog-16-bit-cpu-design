module top_processor
(
    //clk & reset
    CLK,
    RESET,
    //instruction memory
    IMEM_ADDRESS,
    IMEM_DATA,
    //data memory
    DMEM_ADDRESS,
    DMEM_DATA_WRITE,
    DMEM_DATA_READ,
    DMEM_WRITE_ENABLE
);

input  CLK;
input  RESET;
output [15:0] IMEM_ADDRESS;
input  [15:0] IMEM_DATA;
output [15:0] DMEM_ADDRESS;
output [15:0] DMEM_DATA_WRITE;
input  [15:0] DMEM_DATA_READ;
output DMEM_WRITE_ENABLE;

wire [15:0] PC_OUT;
wire [15:0] SRC;
wire [15:0] DEST;
wire [15:0] INST_REG_OUT;
wire [7:0] IMM;
wire [7:0] DISP;
wire [3:0] ADDR_A;
wire [3:0] ADDR_B;
wire [4:0] PSR_FLCNZ_IN;
wire [4:0] PSR_FLCNZ_OUT;
wire [4:0] TRI_SEL;
wire [5:0] ALU_SEL;
wire WR;
wire JMP;
wire BR;
wire IMM_EX_SEL;
wire MUX_SEL0;
wire MUX_SEL1;
wire SHIFT_IMM;
wire LUI;
wire WE;
wire [15:0] MUX0_IN_0;
wire [15:0] MUX0_IN_1;
wire [15:0] MUX0_OUT;
wire [15:0] MUX1_IN_0;
wire [15:0] MUX1_IN_1;
wire [15:0] MUX1_OUT;
wire [4:0] MUX2_IN_0;
wire [4:0] MUX2_IN_1;
wire [4:0] MUX2_OUT;
wire [15:0] TRI_BUF0_IN;
wire [15:0] TRI_BUF1_IN;
wire [15:0] TRI_BUF2_IN;
wire [15:0] TRI_BUF3_IN;
wire [15:0] TRI_BUF4_IN;
wire [15:0] RF_DATA_IN;
   
assign IMEM_ADDRESS = PC_OUT;

assign DMEM_ADDRESS = SRC;
assign DMEM_DATA_WRITE = DEST;
assign DMEM_WRITE_ENABLE = WE;

assign MUX0_IN_0 = SRC;
assign MUX0_IN_1[15:8] = (IMM_EX_SEL == 1'b0) ? 8'h0 : {8{IMM[7]}};
assign MUX0_IN_1[7:0] = IMM;
mux16_2to1
    mux16_2to1_0(
        MUX_SEL0,
        MUX0_IN_0, MUX0_IN_1,
        MUX0_OUT
    );

assign MUX1_IN_0 = DEST;
assign MUX1_IN_1[15:8] = (IMM_EX_SEL == 1'b0) ? 8'h0 : {8{IMM[7]}};
assign MUX1_IN_1[7:0] = IMM;
mux16_2to1
    mux16_2to1_1(
        .MUXSEL(MUX_SEL1),
        .Din0(MUX1_IN_0),
        .Din1(MUX1_IN_1),
        .Dout(MUX1_OUT)
    );

assign MUX2_IN_0 = SRC[4:0];
assign MUX2_IN_1 = IMM[4:0];
mux5_2to1
    mux5_2to1_0(
        .MUXSEL(SHIFT_IMM),
        .Din0(MUX2_IN_0),
        .Din1(MUX2_IN_1),
        .Dout(MUX2_OUT)
    );

tristate_buf16
    tristate_buf16_0(
        .ENABLE(TRI_SEL[0]),
        .Din(TRI_BUF0_IN),
        .Dout(RF_DATA_IN)
    );

tristate_buf16
    tristate_buf16_1(
        .ENABLE(TRI_SEL[1]),
        .Din(TRI_BUF1_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF2_IN = MUX0_OUT;
tristate_buf16
    tristate_buf16_2(
        .ENABLE(TRI_SEL[2]),
        .Din(TRI_BUF2_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF3_IN = PC_OUT;
tristate_buf16
    tristate_buf16_3(
        .ENABLE(TRI_SEL[3]),
        .Din(TRI_BUF3_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF4_IN = DMEM_DATA_READ;
tristate_buf16
    tristate_buf16_4(
        .ENABLE(TRI_SEL[4]),
        .Din(TRI_BUF4_IN),
        .Dout(RF_DATA_IN)
    );

// TODO assign statements needed to connect the modules
// Instantiate the modules and connect them with wires
pc pc_ready(
    .rst_i(RESET),
    .clk_i(CLK),
    .jump_i(JMP),
    .branch_i(BR),
    .displacement_i(DISP),
    .jump_tgt_i(SRC),
    .addr_imem_o(PC_OUT)
);

instruction_reg ir_ready(
    .rst_i(RESET),
    .clk_i(CLK),
    .jump_i(JMP),
    .branch_i(BR),
    .inst_i(IMEM_DATA),
    .inst_o(INST_REG_OUT),
    .imm_o(IMM),
    .displacement_o(DISP),
    .addr_a_o(ADDR_A),
    .addr_b_o(ADDR_B)
);

decoder decoder_ready(
    .inst_i(INST_REG_OUT),
    .psr_flags_i(PSR_FLCNZ_OUT),
    .TRI_SEL(TRI_SEL),
    .ALU_SEL(ALU_SEL),
    .WR(WR),
    .JMP(JMP),
    .BR(BR),
    .IMM_EX_SEL(IMM_EX_SEL),
    .MUX_SEL0(MUX_SEL0),
    .MUX_SEL1(MUX_SEL1),
    .SHIFT_IMM(SHIFT_IMM),
    .LUI(LUI),
    .WE(WE)
);

register_file rf_ready(
    .rst_i(RESET),
    .clk_i(CLK),
    .wr_i(WR),
    .data_i(RF_DATA_IN),
    .addr_a_i(ADDR_A),
    .addr_b_i(ADDR_B),
    .data_a_o(SRC),
    .data_b_o(DEST)
);

alu alu_ready(
    .A_i(MUX0_OUT),
    .B_i(DEST),
    .alu_sel_i(ALU_SEL),
    .flags_o(PSR_FLCNZ_IN),
    .alu_o(TRI_BUF1_IN)
);

psr psr_ready(
    .rst_i(RESET),
    .clk_i(CLK),
    .alu_sel_i(ALU_SEL),
    .flags_i(PSR_FLCNZ_IN),
    .flags_o(PSR_FLCNZ_OUT)
);

shifter shifter_ready(
    .data_i(MUX1_OUT),
    .rl_shift_amt_i(MUX2_OUT),
    .lui_i(LUI),
    .data_o(TRI_BUF0_IN)
);

endmodule

