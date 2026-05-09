`timescale 1ns/1ns

module test_fetch();

reg clk;
reg rst;
reg [15:0] inst_i;
reg [15:0] jmp_tgt;
reg [4:0] psr_flags;

wire jmp;
wire br;
wire [7:0] imm_w;
wire [7:0] disp_w;
wire [3:0] addrA;
wire [3:0] addrB;
wire [15:0] inst_ptr;
wire [15:0] inst_w;

initial begin: gen_clock200MHz
    clk = 1'b1;
    forever begin
        #5
        clk = !clk;
    end
end

initial begin: gen_reset
    rst = 1'b0;
    #(5) rst = 1'b1;
    #(10) rst = 1'b0;
end

initial begin
    jmp_tgt <= 16'h36FF;
    inst_i <= 0;
    psr_flags <= 5'b00001;

    @(negedge rst);

    @(posedge clk);
    inst_i <= 16'h0356; // ADD r3 r6

    @(posedge clk);
    inst_i <= 16'h0396; // SUB r3 r6
    
    @(posedge clk);
    inst_i <= 16'h03B6; // CMP r3 r6
    
    @(posedge clk);
    inst_i <= 16'h0316; // AND r3 r6
    
    @(posedge clk);
    inst_i <= 16'h0326; // OR r3 r6
    
    @(posedge clk);
    inst_i <= 16'h0336; // XOR r3 r6
    
    @(posedge clk);
    inst_i <= 16'h03D6; // MOV r3 r6
    
    @(posedge clk);
    inst_i <= 16'h4306; // LDR r3 r6
    
    @(posedge clk);
    inst_i <= 16'h4346; // STR r3 r6

    @(posedge clk);
    inst_i <= 16'h831D; // LSHI r3 RLSHIFTAMT(5b, -3)

    @(posedge clk);
    inst_i <= 16'hF386; // LUI r3 IMM (r3=IMM<<8)

    @(posedge clk);
    inst_i <= 16'h44C3; //JLT r3 (assume jmp_tgt has been stored in r3)

    @(posedge clk);
    inst_i <= 16'h40C3; //JEQ r3 

    @(posedge clk);
    inst_i <= 16'h0316; // AND r3 r6
    
    @(posedge clk);
    inst_i <= 16'hC4FD; //BLT disp

    @(posedge clk);
    inst_i <= 16'hC0FD; //BEQ disp

    @(posedge clk);
    inst_i <= 16'h0316; // AND r3 r6

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    inst_i <= 16'h4EC3; //JMP r3 

    @(posedge clk);
    inst_i <= 16'h0316; // AND r3 r6

    @(posedge clk);
    inst_i <= 16'h4083; //JAL r0 r3 

    @(posedge clk);
    inst_i <= 16'h0316; // AND r3 r6
end

pc u_pc(
    .rst_i(rst),
    .clk_i(clk),
    .jump_i(jmp),
    .branch_i(br),
    .displacement_i(disp_w),
    .jump_tgt_i(jmp_tgt),

    .addr_imem_o(inst_ptr)
);

instruction_reg u_ir(
    .rst_i(rst),
    .clk_i(clk),
    .jump_i(jmp),
    .branch_i(br),
    .inst_i(inst_i),

    .inst_o(inst_w),
    .imm_o(imm_w),
    .displacement_o(disp_w),
    .addr_a_o(addrA),
    .addr_b_o(addrB)
);

decoder u_id(
    .inst_i(inst_w),
    .psr_flags_i(psr_flags),

    .TRI_SEL(),
    .ALU_SEL(),
    .WR(),
    .JMP(jmp),
    .BR(br),
    .MUX_SEL0(),
    .MUX_SEL1(),
    .SHIFT_IMM(),
    .LUI(),
    .WE()
);

endmodule
