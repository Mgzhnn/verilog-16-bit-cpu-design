`timescale 1ns/1ns

module test_register_file();

reg clk;
reg wr;
reg rst;
reg [3:0] addrA;
reg [3:0] addrB;

reg [15:0] wdata_w;
wire [15:0] dout_a_w;
wire [15:0] dout_b_w;

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
    addrA   <= 0;
    addrB   <= 0;
    wdata_w <= 0;
    wr <= 1'b0;

    @(negedge rst);
    wr <= 1'b1;

    /* 
     * Initialize RF 
     * Small tips for understanding condition: 
     * 1. (addrB<4'b0100) is equivalent with 'if(addrB==4'b0110) break;'
     * placed after loop statements by compiler
     * 2. addrB will be checked with old value @ posedge of clk due to
     * non-blocking assignment
     */
    while (addrB <4'b0110) begin
        @(posedge clk);
        addrB <= addrB + 1;
        wdata_w <= wdata_w + 1;
    end

    @(posedge clk)
    addrB <= 0;
    wr <= 1'b0;

    /* Read contents */
    forever begin
        @(posedge clk)
        addrA <= addrA + 1;
        addrB <= addrB + 1;
    end
end

register_file u_rf(
    .rst_i(rst),
    .clk_i(clk),
    .wr_i(wr),
    .data_i(wdata_w),
    .addr_a_i(addrA),
    .addr_b_i(addrB),

    .data_a_o(dout_a_w),
    .data_b_o(dout_b_w)
);

endmodule
