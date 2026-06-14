//clk divider
module divider(
    input clk,
    output slow_clk
);

reg [26:0] cnt=0;

always @(posedge clk)
    cnt <= cnt + 1;

assign slow_clk = cnt[26];

endmodule
