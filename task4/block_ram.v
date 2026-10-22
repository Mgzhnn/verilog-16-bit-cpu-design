/*
 * This memory is a register-like memory
 * Write takes one cycle
 * Read can be done instantly @ current cycle
 *
 * In IMEM_MODE, reset loads INIT_FILE (one 16-bit binary word per line, any
 * number of lines up to NUM_ENTRIES) and fills the remaining entries with NOP.
 */
module block_ram #(
    parameter IMEM_MODE = 1,
    parameter NUM_ENTRIES = 256,
    parameter INIT_FILE = "imem_img"
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
integer n_loaded;
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        // Fill first; the words loaded below are scheduled later and take precedence
        for (i=0; i<NUM_ENTRIES; i=i+1) begin
            if (IMEM_MODE)
                my_memory[i] <= 16'h0020;   // NOP (OR r0, r0)
            else
                my_memory[i] <= 16'h0000;
        end

        if (IMEM_MODE) begin
            file = $fopen(INIT_FILE, "r");
            if (file == 0) begin
                $display("block_ram: cannot open %0s", INIT_FILE);
            end
            else begin
                n_loaded = 0;
                // $fscanf is a function: it returns the number of items read (1 per word)
                while (n_loaded < NUM_ENTRIES && $fscanf(file, "%b\n", init_line) == 1) begin
                    my_memory[n_loaded] <= init_line;
                    n_loaded = n_loaded + 1;
                end
                $fclose(file);
            end
        end
    end
    else if (wr_i) begin
        my_memory[addr_i] <= wdata_i;
    end
end

assign rdata_o = my_memory[addr_i];

endmodule
