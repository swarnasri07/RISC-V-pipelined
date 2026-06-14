//module for stalling
module stalling(
    input mem_read_E,
    input [4:0] rd_E,       //here for load it rd onl for store it is rs2
    input [4:0] rs1_D,
    input [4:0] rs2_D,
    input [6:0] opcode_D,
    input mem_read_M,
    input [4:0] rd_M,

    output reg stall_F,
    output reg stall_D,
    output reg flush_E
);

wire uses_rs2_D;

assign uses_rs2_D =
    (opcode_D == 7'b0110011) || // R-type
    (opcode_D == 7'b1100011);   // BRANCH       //similarly to avoid the conf between imm and registers

wire decode_needs_rs1;

assign decode_needs_rs1 =
    (opcode_D == 7'b1100011) || // branch
    (opcode_D == 7'b1100111);   // jalr

always@(*)begin

        stall_F=0;
        stall_D=0;
        flush_E=0;

    if(rd_E != 0 &&
   (
      (rd_E == rs1_D && decode_needs_rs1) ||
      (rd_E == rs2_D && opcode_D == 7'b1100011)
   ))   
   begin                                                    //for branch and jalr prediction
    stall_F=1;
    stall_D=1;
    flush_E=1;
    end

    else if(mem_read_E && (rd_E != 0) &&((rd_E == rs1_D) || (uses_rs2_D&&(rd_E == rs2_D)))) begin  //normal stalling
    stall_F=1;
    stall_D=1;
    flush_E=1;
    end

    else if( rd_M != 0 && mem_read_M &&(
            (rd_M == rs1_D && decode_needs_rs1) ||
            (rd_M == rs2_D && opcode_D == 7'b1100011)
            ))
                                                                //for load and branch or jalr
    begin
    stall_F=1;
    stall_D=1;
    flush_E=1;
    end


end

endmodule
