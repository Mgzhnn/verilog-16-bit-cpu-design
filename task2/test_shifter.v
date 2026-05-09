`timescale 1ns/1ns

module test_shifter;

reg [15:0]  data_i;
reg [4:0]   rl_shift_amt;
reg         lui;
wire [15:0] data_o;

integer i = 0;

initial begin: test_sequencer
    lui = 1'b0;
    data_i = 16'hCAFE;
    rl_shift_amt = 0;

    for (i=0; i<=5'b11111; i=i+1) begin
        #5
        rl_shift_amt = i;
    end

    #5
    lui = 1'b1;
end

shifter u_shift(
    .data_i(data_i),
    .rl_shift_amt_i(rl_shift_amt),
    .lui_i(lui),

    .data_o(data_o)
);

endmodule
