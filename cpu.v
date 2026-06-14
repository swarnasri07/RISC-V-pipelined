module cpu(
    input clk,
    input rst,

    output [31:0] debug_mem10
);

//for fetch
wire [31:0] pc_F;
wire [31:0] pc4_F;
wire [31:0] instr_F;
wire stall_F;

wire branch_taken;
wire [31:0] branch_target;
wire jal_taken;
wire [31:0] jal_target;
wire jalr_taken;
wire [31:0] jalr_target;

assign branch_taken  = branch_taken_D;          //since these come from the decode stage 
assign branch_target = branch_target_D;

assign jal_taken     = jal_taken_D;
assign jal_target    = jal_target_D;

assign jalr_taken    = jalr_taken_D;
assign jalr_target   = jalr_target_D;

fetch u_fetch(
    .clk(clk),
    .rst(rst),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .jal_taken(jal_taken),
    .jal_target(jal_target),
    .jalr_taken(jalr_taken),
    .jalr_target(jalr_target),
    .stall_F(stall_F),
    .pc_F(pc_F),
    .pc4_F(pc4_F),
    .instr_F(instr_F)
);

//for regosters from F to D
wire flush_D;
wire [31:0] instr_D;
wire [31:0] pc_D;
wire [31:0] pc4_D;

if_id u_if_id(
    .clk(clk),
    .rst(rst),
    .instr_F(instr_F),
    .pc_F(pc_F),
    .stall_F(stall_F),
    .flush_D(flush_D),
    .pc4_F(pc4_F),
    .instr_D(instr_D),
    .pc_D(pc_D),
    .pc4_D(pc4_D)
);

//new wires for decode

wire reg_write_WB;
wire [31:0] result_WB;
wire [4:0] rd_WB;
wire [1:0] branch_forwardA;
wire [1:0] branch_forwardB;
wire [31:0] alu_rslt_M;

wire we;
wire [31:0] imm_i;
wire [31:0] imm_str;
wire [31:0] imm_j;
wire [31:0] imm_brnch;
wire [6:0] opcode_D;
wire [6:0] func7_D;
wire [2:0] func3_D;
wire [31:0] imm_D;
wire [4:0] rs1_addr_D;
wire [4:0] rs2_addr_D;
wire [31:0] rs1_val_D;
wire [31:0] rs2_val_D;
wire [4:0] rdl_D;
wire reg_write_D;
wire mem_read_D;
wire mem_write_D;
wire [1:0] rslt_src_D;
wire branch_taken_D;
wire [31:0] branch_target_D;
wire jal_taken_D;
wire [31:0] jal_target_D;
wire jalr_taken_D;
wire [31:0] jalr_target_D;

decode u_decode(
    .clk(clk),
    .instr_D(instr_D),
    .reg_write_WB(reg_write_WB),
    .result_WB(result_WB),
    .rd_WB(rd_WB),
    .pc_D(pc_D),
    .branch_forwardA(branch_forwardA),
    .branch_forwardB(branch_forwardB),
    .alu_rslt_M(alu_rslt_M),
    .we(we),
    .imm_i(imm_i),
    .imm_str(imm_str),
    .imm_j(imm_j),
    .imm_brnch(imm_brnch),
    .opcode_D(opcode_D),
    .func7_D(func7_D),
    .func3_D(func3_D),
    .imm_D(imm_D),
    .rs1_addr(rs1_addr_D),
    .rs2_addr(rs2_addr_D),
    .rs1_val_D(rs1_val_D),
    .rs2_val_D(rs2_val_D),
    .rdl(rdl_D),
    .reg_write(reg_write_D),
    .mem_read(mem_read_D),
    .mem_write(mem_write_D),
    .rslt_src(rslt_src_D),
    .branch_taken_D(branch_taken_D),
    .branch_target_D(branch_target_D),
    .jal_taken_D(jal_taken_D),
    .jal_target_D(jal_target_D),
    .jalr_taken_D(jalr_taken_D),
    .jalr_target_D(jalr_target_D),
    .flush_D(flush_D)
);


//execute - decode  stage 

wire [6:0] opcode_E, func7_E;
wire [2:0] func3_E;
wire [31:0] pc_E, pc4_E, imm_E;
wire [31:0] rs1_val_E, rs2_val_E;
wire [4:0] rs1_addr_E, rs2_addr_E, rd_E;
wire reg_write_E, mem_read_E, mem_write_E;
wire [1:0] rslt_src_E;

id_ex u_id_ex(
    .clk(clk),
    .rst(rst),
    .flush_E(flush_E),
    .pc_D(pc_D),
    .imm_D(imm_D),
    .rs1_val_D(rs1_val_D),
    .rs2_val_D(rs2_val_D),
    .rs1_addr_D(rs1_addr_D),
    .rs2_addr_D(rs2_addr_D),
    .rd_D(rdl_D),
    .opcode_D(opcode_D),
    .func3_D(func3_D),
    .func7_D(func7_D),
    .pc4_D(pc4_D),
    .reg_write_D(reg_write_D),
    .mem_read_D(mem_read_D),
    .mem_write_D(mem_write_D),
    .rslt_src_D(rslt_src_D),
    
    .opcode_E(opcode_E),
    .func3_E(func3_E),
    .func7_E(func7_E),
    .pc_E(pc_E),
    .pc4_E(pc4_E),
    .imm_E(imm_E),
    .rs1_val_E(rs1_val_E),
    .rs2_val_E(rs2_val_E),
    .rs1_addr_E(rs1_addr_E),
    .rs2_addr_E(rs2_addr_E),
    .rd_E(rd_E),
    .reg_write_E(reg_write_E),
    .mem_read_E(mem_read_E),
    .mem_write_E(mem_write_E),
    .rslt_src_E(rslt_src_E)
);

//for execute 
wire [31:0] alu_rslt_E;
wire [1:0] forwardA;
wire [1:0] forwardB;
wire [1:0] forward_store;

execute u_execute(
    .func7_E(func7_E),
    .func3_E(func3_E),
    .imm_E(imm_E),
    .rs1_val_E(rs1_val_E),
    .rs2_val_E(rs2_val_E),
    .rd_E(rd_E),
    .opcode_E(opcode_E),
    .pc_E(pc_E),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .alu_rslt_M(alu_rslt_M),
    .result_WB(result_WB),
    .alu_rslt(alu_rslt_E)
);

//for exe-mem
wire [31:0] pc_4_M;
wire [31:0] rs2_val_M;
wire mem_write_M;
wire [1:0] rslt_src_M;
wire [31:0] mem_data_M;
wire [4:0] rd_M;
wire reg_write_M;
wire mem_read_M;

ex_mem u_ex_mem(
    .clk(clk),
    .rst(rst),
    .rd_E(rd_E),
    .pc_4_E(pc4_E),
    .alu_rslt_E(alu_rslt_E), // Assuming you renamed the ports inside module too
    .rs2_val_E(rs2_val_E),
    .forward_store(forward_store),
    .reg_write_E(reg_write_E),
    .mem_read_E(mem_read_E),
    .mem_write_E(mem_write_E),
    .rslt_src_E(rslt_src_E),
    .result_WB(result_WB),
    
    .rd_M(rd_M),
    .pc_4_M(pc_4_M),
    .alu_rslt_M(alu_rslt_M),
    .rs2_val_M(rs2_val_M),
    .reg_write_M(reg_write_M),
    .mem_read_M(mem_read_M),
    .mem_write_M(mem_write_M),
    .rslt_src_M(rslt_src_M)
);

//for mem

memory u_memory(
    .clk(clk),
    .rst(rst),
    .mem_write(mem_write_M),
    .mem_read(mem_read_M),
    .alu_rslt_M(alu_rslt_M),
    .rs2_val_M(rs2_val_M),
    .mem_data_M(mem_data_M),
    .debug_mem10(debug_mem10)
);

//mem to wb and wb stage

wire [31:0] pc_4_WB;
wire [31:0] alu_rslt_WB;
wire [1:0] rslt_src_WB;
wire [31:0] mem_data_WB;

mem_wb u_mem_wb(
    .clk(clk),
    .rst(rst),
    .rd_M(rd_M),
    .pc_4_M(pc_4_M),
    .alu_rslt_M(alu_rslt_M),
    .reg_write_M(reg_write_M),
    .rslt_src_M(rslt_src_M),
    .mem_data_M(mem_data_M),
    
    .rd_WB(rd_WB),
    .pc_4_WB(pc_4_WB),
    .alu_rslt_WB(alu_rslt_WB),
    .reg_write_WB(reg_write_WB),
    .rslt_src_WB(rslt_src_WB),
    .mem_data_WB(mem_data_WB)
);

write_back u_write_back(
    .alu_rslt_WB(alu_rslt_WB),
    .mem_data_WB(mem_data_WB),
    .pc_4_WB(pc_4_WB),
    .rslt_src_WB(rslt_src_WB),
    .result_WB(result_WB)
);

//forwarding and stalling

wire stall_D;
wire flush_E;

forwarding_unit u_forwarding_unit(
    .rs1_E(rs1_addr_E),
    .rs2_E(rs2_addr_E),
    .rd_M(rd_M),
    .reg_write_M(reg_write_M),
    .rd_WB(rd_WB),
    .reg_write_WB(reg_write_WB),
    .opcode_E(opcode_E),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .forward_store(forward_store)
);

branch_forwarding u_branch_forwarding(
    .rs1_D(rs1_addr_D),
    .rs2_D(rs2_addr_D),
    .opcode_D(opcode_D),
    .rd_M(rd_M),
    .reg_write_M(reg_write_M),
    .rd_WB(rd_WB),
    .reg_write_WB(reg_write_WB),
    .branch_forwardA(branch_forwardA),
    .branch_forwardB(branch_forwardB)
);

stalling u_stalling(
    .mem_read_E(mem_read_E),
    .rd_E(rd_E),
    .rs1_D(rs1_addr_D),
    .rs2_D(rs2_addr_D),
    .opcode_D(opcode_D),
    .mem_read_M(mem_read_M),
    .rd_M(rd_M),
    .stall_F(stall_F),
    .stall_D(stall_D),
    .flush_E(flush_E)
);

endmodule