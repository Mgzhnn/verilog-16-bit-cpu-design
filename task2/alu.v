module alu
(
	input [15:0] A_i,
	input [15:0] B_i,
	input [5:0]  alu_sel_i,

	output     [4:0]    flags_o, // F, L, C, N, Z
	output reg [15:0]   alu_o
);

`include "ALU_modes.vh"

reg CARRYIN_w;
wire CARRYOUT_nw;
wire [1:0] alu_ovf_w;
wire [15:0] cla_sum_w;


cla16
	cla16_0(
		.A_i(A_i),
		.B_i(B_i),
		.CARRYIN_i(CARRYIN_w),
		.CARRYOUT_no(CARRYOUT_nw),
		.flag_overflow_o(alu_ovf_w),
		.sum_o(cla_sum_w)
	);


/* F: overflow - here alu_ovf_w[1] is used for signed overflow from previous F/C discussion.
 * L: less than (unsigned) - here CARRYOUT_nw is used, for unsigned comparison, if B < A, then B - A will not have a carry out. So we can use CARRYOUT_nw directly for unsigned comparison.
 * C: carry out (unsigned) - here Calu_ovf_w[0] is used for unsigned overflow from previous F/C discussion.
 * N: negative - here alu_o[15] is used for signed negative and alu_ovf_w[1] is used for signed overflow. For signed comparison, together with signed overflow, if the result is negative, then N is 1, otherwise N is 0. So we can use alu_o[15] XOR alu_ovf_w[1] for signed negative.
 * Z: zero - here we can use a reduction OR operator to check if all bits of alu_o are 0, if all bits are 0, then Z is 1, otherwise Z is 0.
 */
assign flags_o[4] = alu_ovf_w[1]; // F
assign flags_o[3] = CARRYOUT_nw;  // L
assign flags_o[2] = alu_ovf_w[0]; // C
assign flags_o[1] = cla_sum_w[15] ^ alu_ovf_w[1]; // N
assign flags_o[0] = ~(alu_o[0] | alu_o[1] | alu_o[2] | alu_o[3] |
                      alu_o[4] | alu_o[5] | alu_o[6] | alu_o[7] |
                      alu_o[8] | alu_o[9] | alu_o[10] | alu_o[11] |
                      alu_o[12] | alu_o[13] | alu_o[14] | alu_o[15]); // Z


always @(*) begin
	CARRYIN_w = 1'b0;
	alu_o = cla_sum_w;

	case (alu_sel_i)
	ALU_SEL_SUB:
		CARRYIN_w = 1'b1;
	ALU_SEL_CMP:
		CARRYIN_w = 1'b1;
	ALU_SEL_AND:
		alu_o = A_i & B_i;
	ALU_SEL_OR:
		alu_o = A_i | B_i;
	ALU_SEL_XOR:
		alu_o = A_i ^ B_i;
	default:
		;
	endcase
end

endmodule

