module lcu4 //lookahead carry unit
(
    input [3:0] gprop_i,
    input [3:0] ggen_i,
    input       gcarry_i,

    output [3:0] gcarry_o
);

assign gcarry_o[0] = ggen_i[0] | (gprop_i[0] & gcarry_i);
 
assign gcarry_o[1] = ggen_i[1] | (gprop_i[1] & ggen_i[0]) |
            (gprop_i[0] & gprop_i[1] & gcarry_i);
 
assign gcarry_o[2] = ggen_i[2] | (gprop_i[2] & ggen_i[1]) |
            (gprop_i[1] & gprop_i[2] & ggen_i[0]) |
            (gprop_i[0] & gprop_i[1] & gprop_i[2] & gcarry_i);
             
assign gcarry_o[3] = ggen_i[3] | (gprop_i[3] & ggen_i[2]) |
            (gprop_i[2] & gprop_i[3] & ggen_i[1]) |
            (gprop_i[1] & gprop_i[2] & gprop_i[3] & ggen_i[0]) | 
            (gprop_i[0] & gprop_i[1] & gprop_i[2] & gprop_i[3] & gcarry_i);

endmodule

