module reg_file(
    input clk,
    input we,                    //write enable
    input [4:0] rsl1, rsl2, rdl, //register addresses/register numbers
    input [31:0] rd,             //the output vslue that comes from the alu and write that in register rdl
    output [31:0] rs1, rs2       //outputs or the values in given registers
);
    reg [31:0] gpr [31:0];
    integer i;
    initial begin
        for(i=0;i<32;i=i+1)
            gpr[i]=0;
    end
    assign rs1 = (rsl1 == 0) ? 32'b0 : gpr[rsl1];
    assign rs2 = (rsl2 == 0) ? 32'b0 : gpr[rsl2];

    always @(negedge clk) begin
        if(we && rdl!=0)
        gpr[rdl] <= rd;
    end

endmodule
