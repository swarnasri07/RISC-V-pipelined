module fetch(
    input clk,
    input rst,

    input branch_taken,
    input [31:0] branch_target,
    input jal_taken,
    input [31:0] jal_target,
    input jalr_taken,
    input [31:0] jalr_target,
    input stall_F,

    output [31:0] pc_F,
    output [31:0] pc4_F,
    output [31:0] instr_F
);

reg [31:0] pc_reg;
reg [31:0] mem [0:1023];

initial
    $readmemh("program.mem", mem);

always @(posedge clk or posedge rst) begin
    if      (rst)          pc_reg <= 0;
    else if (stall_F)      pc_reg <= pc_reg;
    else if (jalr_taken)   pc_reg <= jalr_target;
    else if (jal_taken)    pc_reg <= jal_target;
    else if (branch_taken) pc_reg <= branch_target;
    else                   pc_reg <= pc_reg + 4;
end

assign pc_F = pc_reg;
assign pc4_F=pc_reg+4;
assign instr_F = mem[pc_reg >> 2];

endmodule

module if_id(
    input clk,
    input rst,

    input  [31:0] instr_F,
    input  [31:0] pc_F,
    input stall_F,
    input flush_D,
    input [31:0]pc4_F,

    output reg [31:0] instr_D,
    output reg [31:0] pc_D,
    output reg [31:0]pc4_D
);

always @(posedge clk or posedge rst) begin
    if (rst || flush_D) begin
        instr_D <= 32'b0;
        pc_D    <= 32'b0;
        pc4_D   <=32'b0;
    end
    else if(!stall_F) begin
        instr_D <= instr_F;
        pc_D    <= pc_F;
        pc4_D   <=pc4_F;
    end
end

endmodule