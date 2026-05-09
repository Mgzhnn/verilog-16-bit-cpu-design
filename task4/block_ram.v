/*
 * This memory is a register-like memory
 * Write takes one cycle
 * Read can be done instantly @ current cycle
 */
module block_ram #(
    parameter IMEM_MODE = 1,
    parameter NUM_ENTRIES = 256
) 
(
    input   clk_i,
    input   rst_i,

    input   wr_i,
    input [15:0]    addr_i,
    input [15:0]    wdata_i,
    
    output [15:0]   rdata_o
);

reg [15:0] my_memory [0:NUM_ENTRIES-1];

reg [15:0] init_line;

integer file;
integer i;
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        if (IMEM_MODE)
            file = $fopen("imem_img", "rb");

        for (i=0; i<NUM_ENTRIES; i=i+1) begin
            if (IMEM_MODE!=0 && i<21) begin
                $fscanf(file, "%b\n", init_line);
                my_memory[i] <= init_line;
            end
            else if(IMEM_MODE)
                my_memory[i] <= 16'h0020;
            else
                my_memory[i] <= 16'h0000;
        end

        $fclose(file);
    end
    else if (wr_i) begin
        my_memory[addr_i] <= wdata_i;
    end
end

assign rdata_o = my_memory[addr_i];

endmodule

