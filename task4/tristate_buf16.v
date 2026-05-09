module tristate_buf16
(
	//input
	ENABLE,
	Din,
	//output
	Dout
);

input ENABLE;
input [15:0] Din;
output [15:0] Dout;

assign Dout = (ENABLE == 1'b1) ? Din : 16'hzzzz;

endmodule

