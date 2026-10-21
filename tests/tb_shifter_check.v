`timescale 1ns/1ns

// Self-checking shifter test: every signed shift amount (-16..15, negative = right,
// logical) on random data, plus LUI ({data[7:0], 8'h00}).
module tb_shifter_check;

reg  [15:0] data;
reg  [4:0]  amt;
reg         lui;
wire [15:0] out;

shifter u_shift(
    .data_i(data),
    .rl_shift_amt_i(amt),
    .lui_i(lui),
    .data_o(out)
);

reg [15:0] want;
integer n, k, errors;

initial begin
    errors = 0;
    for (n = 0; n < 2000; n = n + 1) begin
        for (k = -16; k < 16; k = k + 1) begin
            data = $random;
            amt = k;
            lui = 1'b0;
            #1;
            want = (k >= 0) ? (data << k) : (data >> (-k));
            if (out !== want) begin
                errors = errors + 1;
                if (errors <= 5) $display("shift: data=%h amount=%0d got %h want %h", data, k, out, want);
            end

            lui = 1'b1;
            #1;
            if (out !== {data[7:0], 8'h00}) begin
                errors = errors + 1;
                if (errors <= 5) $display("lui: data=%h got %h", data, out);
            end
        end
    end

    if (errors == 0) $display("PASS tb_shifter_check: 64000 shifts, 64000 LUI");
    else             $display("FAIL tb_shifter_check: %0d mismatches", errors);
    $finish;
end

endmodule
