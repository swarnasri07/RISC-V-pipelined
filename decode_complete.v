module decode(
    input clk,                  //to give it to decode 
    input [31:0]instr_D,
    input reg_write_WB,
    input [31:0]result_WB,
    input [4:0]rd_WB,
    input [31:0] pc_D,
    input [1:0] branch_forwardA,
    input [1:0] branch_forwardB,
    input [31:0] alu_rslt_M,
    
    output we,
    output [31:0]imm_i,
    output [31:0]imm_str,
    output [31:0]imm_j,
    output [31:0]imm_brnch,
    output [6:0]opcode_D,
    output [6:0]func7_D,
    output [2:0]func3_D,
    output reg[31:0]imm_D,
    output [4:0] rs1_addr,
    output [4:0] rs2_addr,
    output [31:0]rs1_val_D,
    output [31:0]rs2_val_D, 
    output [4:0]rdl,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] rslt_src,
    output reg branch_taken_D,
    output [31:0] branch_target_D,
    output jal_taken_D,
    output [31:0] jal_target_D,
    output jalr_taken_D,
    output [31:0] jalr_target_D,
    output flush_D
);

    assign opcode_D = instr_D[6:0];

    //Extract func7
    assign func7_D = instr_D[31:25];

    //Extract func3
    assign func3_D = instr_D[14:12];

    wire [4:0] rd_addr;

    //getting registers
    assign rs1_addr = instr_D[19:15];
    assign rs2_addr = instr_D[24:20];
    assign rd_addr  = instr_D[11:7];

    //to generate immediates
    assign imm_i={{20{instr_D[31]}},instr_D[31:20]};   //to ensure that imm is 32 bit so thaat alu_src2 size remiains same

    assign imm_str={{20{instr_D[31]}},instr_D[31:25],instr_D[11:7]};   //for store type immediate generation

    assign imm_j = {{11{instr_D[31]}}, instr_D[31], instr_D[19:12], instr_D[20], instr_D[30:21], 1'b0};

    assign imm_brnch = {{19{instr_D[31]}},instr_D[31],instr_D[7],instr_D[30:25],instr_D[11:8],1'b0};

    //since it is not write back stage
    assign we = reg_write_WB;
    assign rdl = rd_WB;

    assign jal_target_D = pc_D + imm_j;


    reg_file register(
        .we(we),
        .rsl1(rs1_addr),
        .rsl2(rs2_addr),
        .rdl(rd_WB),
        .rs1(rs1_val_D),
        .rs2(rs2_val_D),
        .clk(clk),
        .rd(result_WB));

    //for imm
    always @(*) begin
        case(opcode_D)

            7'b0010011, // I-type ALU
            7'b0000011, // LOAD
            7'b1100111: // JALR
                imm_D = imm_i;

            7'b0100011: // STORE
                imm_D = imm_str;

            7'b1100011: // BRANCH
                imm_D = imm_brnch;

            7'b1101111: // JAL
                imm_D = imm_j;

            7'b0110111, // LUI
            7'b0010111: // AUIPC
                imm_D = {instr_D[31:12],12'b0};

            default:
                imm_D = 32'b0;

        endcase
    end

    always @(*) begin

        mem_write = 0;
        mem_read  = 0;
        reg_write = 0;
        rslt_src  = 2'b00;
        case(opcode_D)

            // R-type
            7'b0110011: begin
                reg_write = 1;
                rslt_src  = 2'b00; // ALU
            end

            // I-type
            7'b0010011: begin
                reg_write = 1;
                rslt_src  = 2'b00; // ALU
            end

            // LOAD
            7'b0000011: begin
                mem_read  = 1;
                reg_write = 1;
                rslt_src  = 2'b01; // Memory
            end

            // STORE
            7'b0100011: begin
                mem_write = 1;
            end

            // BRANCH
            7'b1100011: begin
                // nothing
            end

            // JAL
            7'b1101111: begin
                reg_write = 1;
                rslt_src  = 2'b10; // PC+4
            end

            // JALR
            7'b1100111: begin
                reg_write = 1;
                rslt_src  = 2'b10; // PC+4
            end

            // LUI
            7'b0110111: begin
                reg_write = 1;
                rslt_src  = 2'b00; // ALU
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1;
                rslt_src  = 2'b00; // ALU
            end

        endcase

    end

    //to correctly decide the operands

    reg [31:0] branch_rs1;  
    reg [31:0] branch_rs2;

    always @(*) begin

        case(branch_forwardA)
            2'b00: branch_rs1 = rs1_val_D;
            2'b01: branch_rs1 = result_WB;
            2'b10: branch_rs1 = alu_rslt_M;
            default: branch_rs1 = rs1_val_D;
        endcase

        case(branch_forwardB)
            2'b00: branch_rs2 = rs2_val_D;
            2'b01: branch_rs2 = result_WB;
            2'b10: branch_rs2 = alu_rslt_M;
            default: branch_rs2 = rs2_val_D;
        endcase

    end

        assign jalr_target_D = (branch_rs1 + imm_i) & 32'hFFFFFFFE;         //addi x5,x0,10 jalr x0,x5,0
                                                                        //the value of x5 may need forwarding from MEM/WB.

    //to find the branch and next pc value 
    assign branch_target_D = pc_D + imm_brnch;

    //comparator to know whether branch was taken or not in decode stage only

    always @(*) begin

        branch_taken_D = 1'b0;

        if(opcode_D == 7'b1100011) begin

            case(func3_D)

                3'b000: branch_taken_D = (branch_rs1 == branch_rs2); // BEQ

                3'b001: branch_taken_D = (branch_rs1 != branch_rs2); // BNE

                3'b100: branch_taken_D =
                            ($signed(branch_rs1) < $signed(branch_rs2)); // BLT

                3'b101: branch_taken_D =
                            ($signed(branch_rs1) >= $signed(branch_rs2)); // BGE

                3'b110: branch_taken_D =
                            (branch_rs1 < branch_rs2); // BLTU

                3'b111: branch_taken_D =
                            (branch_rs1 >= branch_rs2); // BGEU

                default: branch_taken_D = 1'b0;

            endcase

        end

    end

    assign jal_taken_D  = (opcode_D == 7'b1101111);
    assign jalr_taken_D = (opcode_D == 7'b1100111);
    assign flush_D = branch_taken_D ||
        jal_taken_D ||
        jalr_taken_D;


endmodule

module id_ex(
    input clk,
    input rst,
    input flush_E,
    input [31:0] pc_D,
    input [31:0] imm_D,
    input [31:0] rs1_val_D,
    input [31:0] rs2_val_D,

    input [4:0] rd_D,

    input [6:0] opcode_D,
    input [2:0] func3_D,
    input [6:0] func7_D,
    input [31:0]pc4_D,

    input reg_write_D,
    input mem_read_D,
    input mem_write_D,
    input [1:0] rslt_src_D,
    input [4:0] rs1_addr_D,
    input [4:0] rs2_addr_D,
    output reg [4:0] rs1_addr_E,
    output reg [4:0] rs2_addr_E,

    output reg [6:0] opcode_E,
    output reg [2:0] func3_E,
    output reg [6:0] func7_E,

    output reg [31:0] pc_E,
    output reg [31:0] pc4_E,
    output reg [31:0] imm_E,

    output reg [31:0] rs1_val_E,
    output reg [31:0] rs2_val_E,

    output reg [4:0] rd_E,

    output reg reg_write_E,
    output reg mem_read_E,
    output reg mem_write_E,
    output reg [1:0] rslt_src_E
);

always @(posedge clk or posedge rst) begin

    if(rst||flush_E) begin

        pc_E         <= 0;
        pc4_E        <= 0;
        imm_E        <= 0;
        rs1_val_E    <= 0;
        rs2_val_E    <= 0;
        rd_E         <= 0;
        opcode_E     <= 0;
        func7_E      <= 0;
        func3_E      <= 0;
        reg_write_E  <= 0;
        mem_read_E   <= 0;
        mem_write_E  <= 0;
        rslt_src_E   <= 0;
        pc4_E<=0;
        rs1_addr_E <= 0;
        rs2_addr_E <= 0;

    end
    else  begin

        pc_E         <= pc_D;
        pc4_E        <= pc4_D;
        imm_E        <= imm_D;
        rs1_val_E    <= rs1_val_D;
        rs2_val_E    <= rs2_val_D;
        rd_E         <= rd_D;
        opcode_E     <= opcode_D;
        func7_E      <= func7_D;
        func3_E      <= func3_D;
        reg_write_E  <= reg_write_D;
        mem_read_E   <= mem_read_D;
        mem_write_E  <= mem_write_D;
        rslt_src_E   <= rslt_src_D;
        pc4_E        <= pc4_D;
        rs1_addr_E <= rs1_addr_D;
        rs2_addr_E <= rs2_addr_D;

    end

end

endmodule