module memory(
    input clk,
    input rst,
    input slow_en,
    input mem_write,
    input mem_read,
    input [31:0] alu_rslt_M,
    input [31:0] rs2_val_M,

    output reg [31:0] mem_data_M
);

reg [31:0] main_mem [0:1023];
wire [9:0] addr;
assign addr = alu_rslt_M[11:2]; 

always@(*)begin
    if(mem_read)begin
        mem_data_M = main_mem[addr];
    end
    else
        mem_data_M=0;
end

    always@(posedge clk)begin
        if(slow_en && mem_write) 
            main_mem[addr]<=rs2_val_M;

    end

endmodule


module mem_wb(
    input clk,
    input rst,
    input slow_en,
    input [4:0] rd_M,
    input [31:0] pc_4_M,
    input [31:0] alu_rslt_M,
    input reg_write_M,
    input [1:0] rslt_src_M,
    input [31:0] mem_data_M,

    output reg [4:0] rd_WB,
    output reg [31:0] pc_4_WB,
    output reg [31:0] alu_rslt_WB,
    output reg reg_write_WB,
    output reg [1:0] rslt_src_WB,
    output reg [31:0] mem_data_WB
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        rd_WB        <= 5'b0;
        pc_4_WB      <= 32'b0;
        alu_rslt_WB   <= 32'b0;
        reg_write_WB <= 1'b0;
        rslt_src_WB  <= 2'b0;
        mem_data_WB  <= 32'b0;
    end
    else if (slow_en) begin
        rd_WB        <= rd_M;
        pc_4_WB      <= pc_4_M;
        alu_rslt_WB   <= alu_rslt_M;
        reg_write_WB <= reg_write_M;
        rslt_src_WB  <= rslt_src_M;
        mem_data_WB  <= mem_data_M;
    end
end

endmodule

