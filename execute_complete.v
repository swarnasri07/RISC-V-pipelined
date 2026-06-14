module execute(
    input [6:0]func7_E,
    input [2:0]func3_E,
    input [31:0]imm_E,
    input [31:0]rs1_val_E,
    input [31:0]rs2_val_E,
    input [4:0]rd_E,
    input [6:0]opcode_E,
    input [31:0]pc_E,
    input [1:0]forwardA,
    input [1:0]forwardB,
    input [31:0] alu_rslt_M,
    input [31:0]result_WB,

    output reg[31:0]alu_rslt
    );

    reg [31:0]alu_src1_orig, alu_src2_orig, alu_src1, alu_src2;

    always @(*) begin

        alu_src1_orig = rs1_val_E;
        alu_src2_orig = rs2_val_E;

        case(opcode_E)

            7'b0110011: begin   // R-type
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = rs2_val_E;
            end

            7'b0010011: begin   // I-type ALU
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = imm_E;
            end

            7'b0000011: begin   // LOAD
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = imm_E;
            end

            7'b0100011: begin   // STORE
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = imm_E;
            end 

            7'b1100011: begin   // BRANCH
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = rs2_val_E;
            end

            7'b1101111: begin   // JAL
                alu_src1_orig = pc_E;
                alu_src2_orig = imm_E;
            end

            7'b1100111: begin   // JALR
                alu_src1_orig = rs1_val_E;
                alu_src2_orig = imm_E;
            end

            7'b0110111: begin   // LUI
                alu_src1_orig = 32'b0;
                alu_src2_orig = imm_E;
            end

            7'b0010111: begin   // AUIPC
                alu_src1_orig = pc_E;
                alu_src2_orig = imm_E;
            end

            default: begin
                alu_src1_orig = 32'b0;
                alu_src2_orig = 32'b0;
            end

        endcase
    end

    always @(*) begin

        case(forwardA)

            2'b00: alu_src1 = alu_src1_orig;
            2'b01: alu_src1 =result_WB;
            2'b10: alu_src1 = alu_rslt_M;
            default: alu_src1= alu_src1_orig;

        endcase

        case(forwardB)

            2'b00: alu_src2 = alu_src2_orig;
            2'b01: alu_src2 =result_WB;
            2'b10: alu_src2 = alu_rslt_M;
            default: alu_src2 = alu_src2_orig;

        endcase
    end


    //for operations
    always @(*) begin

        case(opcode_E)

            // R-type
            7'b0110011: begin
                case({func7_E,func3_E})

                    10'b0000000_000: alu_rslt = alu_src1 + alu_src2; // ADD
                    10'b0100000_000: alu_rslt = alu_src1 - alu_src2; // SUB

                    10'b0000000_001: alu_rslt = alu_src1 << alu_src2[4:0]; // SLL

                    10'b0000000_010: alu_rslt = ($signed(alu_src1) < $signed(alu_src2)); // SLT

                    10'b0000000_011: alu_rslt = (alu_src1 < alu_src2); // SLTU

                    10'b0000000_100: alu_rslt = alu_src1 ^ alu_src2; // XOR

                    10'b0000000_101: alu_rslt = alu_src1 >> alu_src2[4:0]; // SRL

                    10'b0100000_101: alu_rslt = $signed(alu_src1) >>> alu_src2[4:0]; // SRA

                    10'b0000000_110: alu_rslt = alu_src1 | alu_src2; // OR

                    10'b0000000_111: alu_rslt = alu_src1 & alu_src2; // AND

                    default: alu_rslt = 32'b0;

                endcase
            end

            // I-type
            7'b0010011: begin
                case(func3_E)

                    3'b000: alu_rslt = alu_src1 + alu_src2; // ADDI

                    3'b010: alu_rslt = ($signed(alu_src1) < $signed(alu_src2)); // SLTI

                    3'b011: alu_rslt = (alu_src1 < alu_src2); // SLTIU

                    3'b100: alu_rslt = alu_src1 ^ alu_src2; // XORI

                    3'b110: alu_rslt = alu_src1 | alu_src2; // ORI

                    3'b111: alu_rslt = alu_src1 & alu_src2; // ANDI

                    3'b001: alu_rslt = alu_src1 << alu_src2[4:0]; // SLLI

                    3'b101: begin
                        if(func7_E == 7'b0000000)
                            alu_rslt = alu_src1 >> alu_src2[4:0]; // SRLI
                        else
                            alu_rslt = $signed(alu_src1) >>> alu_src2[4:0]; // SRAI
                    end

                    default: alu_rslt = 32'b0;

                endcase
            end

            // LOAD
            7'b0000011:
                alu_rslt = alu_src1 + alu_src2;

            // STORE
            7'b0100011:
                alu_rslt = alu_src1 + alu_src2;

            // BRANCH target
            7'b1100011:
                alu_rslt = pc_E + imm_E;

            // JAL target
            7'b1101111:
                alu_rslt = alu_src1 + alu_src2;

            // JALR target
            7'b1100111:
                alu_rslt = (alu_src1 + alu_src2) & 32'hFFFFFFFE;

            // LUI
            7'b0110111:
                alu_rslt = alu_src2;

            // AUIPC
            7'b0010111:
                alu_rslt = alu_src1 + alu_src2;

            default:
                alu_rslt = 32'b0;

        endcase

    end

endmodule

module ex_mem(
    input clk,
    input rst,
    input [4:0] rd_E,
    input [31:0] pc_4_E,
    input [31:0] alu_rslt_E,
    input [31:0] rs2_val_E,
    input [1:0]forward_store,
    input reg_write_E,
    input mem_read_E,
    input mem_write_E,
    input [1:0] rslt_src_E,
    input [31:0]result_WB,

    output reg [4:0] rd_M,
    output reg [31:0] pc_4_M,
    output reg [31:0] alu_rslt_M,
    output reg [31:0] rs2_val_M,
    output reg reg_write_M,
    output reg mem_read_M,
    output reg mem_write_M,
    output reg [1:0] rslt_src_M
);

always @(posedge clk or posedge rst) begin

    if(rst) begin

        rd_M         <= 0;
        pc_4_M       <= 0;
        alu_rslt_M    <= 0;
        rs2_val_M    <= 0;
        reg_write_M  <= 0;
        mem_read_M   <= 0;
        mem_write_M  <= 0;
        rslt_src_M   <= 0;

    end

    else begin

        rd_M         <= rd_E;
        pc_4_M       <= pc_4_E;
        alu_rslt_M    <= alu_rslt_E;
        if(forward_store==2'b10)
            rs2_val_M <= alu_rslt_M;    
        else if(forward_store==2'b01)
            rs2_val_M<=result_WB;       // old alu_rslt_M = previous instruction result
        else 
            rs2_val_M <= rs2_val_E;
        reg_write_M  <= reg_write_E;
        mem_read_M   <= mem_read_E;
        mem_write_M  <= mem_write_E;
        rslt_src_M   <= rslt_src_E;

    end

end

endmodule
