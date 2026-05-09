module shifter
(
	input [15:0]    data_i,
	input [4:0]     rl_shift_amt_i,
	input           lui_i,

	output [15:0]   data_o
);

wire [30:0] stage_0;
wire [22:0] stage_1;
wire [18:0] stage_2;
wire [16:0] stage_3;
wire [15:0] stage_4;


/* TODO: Please write down codes for each stage */
// Define intermediate results on the way
wire [15:0] r3, r2, r1, r0;
wire [15:0] l3, l2, l1, l0;
wire [15:0] result;
reg [15:0] data_out_r;


// The following part implements 2's complement for shift amount without using any arithmetic operation (+1).
wire shift_right;
wire [4:0] sign_mask;
wire [4:0] shift_xor;
wire [3:0] shift_amt;
 	
assign shift_right = rl_shift_amt_i[4];
assign sign_mask   = {5{shift_right}};
assign shift_xor   = rl_shift_amt_i ^ sign_mask;

assign shift_amt[0] = shift_right ^ shift_xor[0];
assign shift_amt[1] = shift_xor[1] ^ (shift_right & shift_xor[0]);
assign shift_amt[2] = shift_xor[2] ^ (shift_right & shift_xor[1] & shift_xor[0]);
assign shift_amt[3] = shift_xor[3] ^ (shift_right & shift_xor[2] & shift_xor[1] & shift_xor[0]);


// The following part implements the shift operation using 4 stages of multiplexers.
assign r3 = (shift_amt[3]) ? {8'b0, data_i[15:8]} : data_i;
assign l3 = (shift_amt[3]) ? {data_i[7:0], 8'b0} : data_i;

assign r2 = (shift_amt[2]) ? {4'b0, r3[15:4]} : r3;
assign l2 = (shift_amt[2]) ? {l3[11:0], 4'b0} : l3;

assign r1 = (shift_amt[1]) ? {2'b0, r2[15:2]} : r2;
assign l1 = (shift_amt[1]) ? {l2[13:0], 2'b0} : l2;

assign r0 = (shift_amt[0]) ? {1'b0, r1[15:1]} : r1;
assign l0 = (shift_amt[0]) ? {l1[14:0], 1'b0} : l1;


// If shift amount is negative, use right shift path.
// Otherwise, use left shift path.
assign result = (shift_right) ? r0 : l0;


//What if -16 Case? 5'b10000 is -16 in 2's
wire shift_16;
assign shift_16 = (rl_shift_amt_i == 5'b10000); 


// Choose the output based on the control signal. If lui_i is high, output should be {data_i[7:0], 8'b0}.
// If shift amount is -16, output should be 16'b0. Otherwise, output should be the result from the shifter.
always @(*) begin
    if (lui_i == 1'b1) begin
        data_out_r = {data_i[7:0], 8'b0};
    end
    else if (shift_16 == 1'b1) begin
        data_out_r = 16'b0;
    end
    else begin
        data_out_r = result;
    end
end

assign data_o = data_out_r;

endmodule

