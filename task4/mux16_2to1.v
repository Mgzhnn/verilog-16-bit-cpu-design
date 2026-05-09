module mux16_2to1
(
	//input
	MUXSEL,
	Din0,
	Din1,
	//output
	Dout
);

input MUXSEL;
input [15:0] Din0;
input [15:0] Din1;
output [15:0] Dout;
   
assign Dout = (MUXSEL == 1'b0) ? Din0 : Din1;

endmodule

