//to select adn forwarding

module forwarding_unit(

    input [4:0] rs1_E,
    input [4:0] rs2_E,

    input [4:0] rd_M,
    input reg_write_M,

    input [4:0] rd_WB,
    input reg_write_WB,
    input [6:0]opcode_E,
    

    output reg [1:0] forwardA,
    output reg [1:0] forwardB,
    output reg [1:0]forward_store

);

    wire uses_rs2;
    assign uses_rs2 =
        (opcode_E == 7'b0110011) || // R-type   this is because if add  x7, x1, x2
                                                                 //addi x5, x3, 7 7==x7 showas and alu_src2gets overwritten
        (opcode_E == 7'b1100011);   // BRANCH


always @(*) begin

    forwardA = 2'b00;
    forwardB = 2'b00;
    forward_store = 2'b00;

    if(reg_write_M && (rd_M != 0) && (rd_M == rs1_E))
        forwardA = 2'b10;
    else if(reg_write_WB && (rd_WB != 0) && (rd_WB == rs1_E))
        forwardA = 2'b01;

    if(uses_rs2 &&reg_write_M &&(rd_M != 0) &&(rd_M == rs2_E))
        forwardB = 2'b10;
    else if(uses_rs2 && reg_write_WB && (rd_WB != 0) && (rd_WB == rs2_E))
        forwardB = 2'b01;

    //may be add and some other instr and store then it has to also check wb one also 

    if(opcode_E == 7'b0100011 && reg_write_M &&(rd_M != 0) && (rd_M == rs2_E))
        forward_store=2'b10;
    else if(opcode_E == 7'b0100011 && reg_write_WB && (rd_WB != 0) && (rd_WB == rs2_E)) 
        forward_store=2'b01;

end

endmodule

///branch forwarding unit
module branch_forwarding(
    input [4:0] rs1_D,
    input [4:0] rs2_D,
    input [6:0]opcode_D,

    input [4:0] rd_M,
    input reg_write_M,

    input [4:0] rd_WB,
    input reg_write_WB,

    output reg [1:0] branch_forwardA,
    output reg [1:0] branch_forwardB
);

wire needs_decode_forward;

assign needs_decode_forward =
       (opcode_D == 7'b1100011) || // branch
       (opcode_D == 7'b1100111);   // jalr

always@(*)begin

    branch_forwardA = 2'b00;
    branch_forwardB = 2'b00;

    if(needs_decode_forward && reg_write_M &&
        (rd_M != 0) &&
        (rd_M == rs1_D))
        branch_forwardA = 2'b10;

    else if(needs_decode_forward && reg_write_WB &&
            (rd_WB != 0) &&
            (rd_WB == rs1_D))
        branch_forwardA = 2'b01;

    if(opcode_D == 7'b1100011 && reg_write_M &&
        (rd_M != 0) &&
        (rd_M == rs2_D))
        branch_forwardB = 2'b10;

    else if(opcode_D == 7'b1100011 && reg_write_WB &&
            (rd_WB != 0) &&
            (rd_WB == rs2_D))
        branch_forwardB = 2'b01;
    
end
endmodule
