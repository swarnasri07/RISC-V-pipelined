module write_back(
    input [31:0] alu_rslt_WB,
    input [31:0] mem_data_WB,
    input [31:0] pc_4_WB,
    input [1:0] rslt_src_WB,

    output reg [31:0] result_WB
);

always @(*) begin
    case(rslt_src_WB)
        2'b00: result_WB = alu_rslt_WB;   // ALU instructions
        2'b01: result_WB = mem_data_WB;  // Load instructions
        2'b10: result_WB = pc_4_WB;      // JAL/JALR
        default: result_WB = 32'b0;
    endcase
end

endmodule