`timescale 1ns/1ns

// Processor with instruction and data memory, loading the program in PROGRAM.
// Clock period 10 ns; reset is released at 15 ns.
module cpu_harness #(
    parameter PROGRAM = "task4/imem_img"
) ();

reg CLK;
reg RESET;

wire [15:0] IMEM_ADDRESS;
wire [15:0] IMEM_DATA;
wire [15:0] DMEM_ADDRESS;
wire [15:0] DMEM_DATA_READ;
wire [15:0] DMEM_DATA_WRITE;
wire DMEM_WRITE_ENABLE;

initial begin
    CLK = 1'b1;
    forever #5 CLK = !CLK;
end

initial begin
    RESET = 1'b0;
    #5  RESET = 1'b1;
    #10 RESET = 1'b0;
end

top_processor u_proc(
    .CLK(CLK),
    .RESET(RESET),
    .IMEM_ADDRESS(IMEM_ADDRESS),
    .IMEM_DATA(IMEM_DATA),
    .DMEM_ADDRESS(DMEM_ADDRESS),
    .DMEM_DATA_READ(DMEM_DATA_READ),
    .DMEM_DATA_WRITE(DMEM_DATA_WRITE),
    .DMEM_WRITE_ENABLE(DMEM_WRITE_ENABLE)
);

block_ram #(
    .IMEM_MODE(1),
    .INIT_FILE(PROGRAM)
) u_imem(
    .clk_i(CLK),
    .rst_i(RESET),
    .wr_i(1'b0),
    .addr_i(IMEM_ADDRESS),
    .wdata_i(16'h0000),
    .rdata_o(IMEM_DATA)
);

block_ram #(
    .IMEM_MODE(0),
    .NUM_ENTRIES(65536)
) u_dmem(
    .clk_i(CLK),
    .rst_i(RESET),
    .wr_i(DMEM_WRITE_ENABLE),
    .addr_i(DMEM_ADDRESS),
    .wdata_i(DMEM_DATA_WRITE),
    .rdata_o(DMEM_DATA_READ)
);

endmodule
