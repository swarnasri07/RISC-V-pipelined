
// for fpga implementation of Risc V

//to conver the binary number to bcd
module bin_to_bcd(
    input  [13:0] bin,      // max 6765 fits in 14 bits
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] units
);

reg [13:0] shift;
reg [3:0]  thou, hund, ten, unit;
integer i;

always @(*) begin
    thou  = 0;
    hund  = 0;
    ten   = 0;
    unit  = 0;
    shift = bin;

    for (i = 0; i < 14; i = i + 1) begin
        // add 3 if any BCD digit >= 5
        if (thou  >= 5) thou  = thou  + 3;
        if (hund  >= 5) hund  = hund  + 3;
        if (ten   >= 5) ten   = ten   + 3;
        if (unit  >= 5) unit  = unit  + 3;

        // shift left 1
        thou  = {thou[2:0],  hund[3]};
        hund  = {hund[2:0],  ten[3]};
        ten   = {ten[2:0],   unit[3]};
        unit  = {unit[2:0],  shift[13]};
        shift = {shift[12:0], 1'b0};
    end

    thousands = thou;
    hundreds  = hund;
    tens      = ten;
    units     = unit;
end

endmodule

//seven segment decoder
module seven_seg_decoder(output reg [6:0] seg,input [3:0]digit);

always @(*) 
begin
    case(digit)
    //in basys 3 board it is active low;
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        4'd10: seg= 7'b0001000;
        4'd11: seg= 7'b0000011;
        4'd12: seg= 7'b1000110;
        4'd13: seg= 7'b0100001;
        4'd14: seg= 7'b0000110;
        4'd15: seg= 7'b0001110;
        default: seg = 7'b1111111; // all OFF
    endcase
end
endmodule

//to see all the 4 digits in fpga, we should flicker to so fastly
module main(input clk,input rst,output reg [3:0]an,output [6:0] seg);
    wire [3:0]ones,tens,hund,thou;
    wire [31:0] val_in_r10;
    wire slow_clk;

    divider div(.clk(clk), .slow_clk(slow_clk));

    cpu mycpu(
        .clk(slow_clk),
        .rst(rst),
        .debug_mem10(val_in_r10)
    );

    bin_to_bcd uu(
        .bin      (val_in_r10[13:0]),
        .units    (ones),
        .tens     (tens),
        .hundreds (hund),
        .thousands(thou)
    );
    reg [15:0] refresh_counter;
    always @(posedge clk or posedge rst) begin
        if (rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
        end

    wire refresh_clk;
    assign refresh_clk=refresh_counter[15];
    always@(posedge refresh_clk or posedge rst) begin
        if (rst) an <= 4'b1110;
        else begin
        case(an)
            4'b1110: an <= 4'b1101;
            4'b1101: an <= 4'b1011;
            4'b1011: an <= 4'b0111;
            4'b0111: an <= 4'b1110;
            default:  an <= 4'b1110;
        endcase
        end
    end
    reg [3:0] digit;
    always @(*) begin
        case(an)
            4'b1110: digit = ones;
            4'b1101: digit = tens;
            4'b1011: digit = hund;
            4'b0111: digit = thou;
            default:  digit = ones;
        endcase
    end


    
    seven_seg_decoder m(.digit(digit), .seg(seg));
    
endmodule