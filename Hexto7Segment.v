`define dig0 displayCode[3:0]
`define dig1 displayCode[7:4]
module HexTo7Segment (displayCode, Val, Place, OutClk, DisplayFlag);
input OutClk, DisplayFlag;
input [7:0] displayCode;
output reg [7:0] Val;
output reg [3:0] Place;

reg [7:0] seven [1:0];
// All numbers include the decimal point to differenciate from
// the letters
parameter seven0 = 8'b10000000, seven1 = 8'b11110010, seven2 = 8'b01001000, 
    seven3 = 8'b01100000, seven4 = 8'b00110010, seven5 = 8'b00100100, seven6 = 8'b00000100,
    seven7 = 8'b11110000, seven8 = 8'b00000000, seven9 = 8'b00100000, sevenDefault = 8'b11111111, 
    sevenA = 8'b00010001, sevenB = 8'b00000001, sevenC = 8'b10001101, sevenD = 8'b10000001,
    sevenE = 8'b00001101, sevenF = 8'b00011101;

wire [3:0] select [3:0];
integer i = 0;

assign select[0] = 4'b1110;
assign select[1] = 4'b1101;
assign select[2] = 4'b1011;
assign select[3] = 4'b0111;

//A is MSB, G is LSB
always @(displayCode)begin
//case (Thous)
//	0 : seven[3] = seven0;
//	1 : seven[3] = seven1;
//	2 : seven[3] = seven2;
//	3 : seven[3] = seven3;
//	4 : seven[3] = seven4;
//	5 : seven[3] = seven5;
//	6 : seven[3] = seven6;
//	7 : seven[3] = seven7;
//	8 : seven[3] = seven8;
//	9 : seven[3] = seven9;
//	10: seven[3] = sevenA;
//	11: seven[3] = sevenB;
//	12: seven[3] = sevenC;
//	13: seven[3] = sevenD;
//	14: seven[3] = sevenE;
//	15: seven[3] = sevenF;
//	default: seven[3] = sevenDefault;
//endcase
//case (Hund)
//	0 : seven[2] = seven0;
//	1 : seven[2] = seven1;
//	2 : seven[2] = seven2;
//	3 : seven[2] = seven3;
//	4 : seven[2] = seven4;
//	5 : seven[2] = seven5;
//	6 : seven[2] = seven6;
//	7 : seven[2] = seven7;
//	8 : seven[2] = seven8;
//	9 : seven[2] = seven9;
//	10: seven[2] = sevenA;
//	11: seven[2] = sevenB;
//	12: seven[2] = sevenC;
//	13: seven[2] = sevenD;
//	14: seven[2] = sevenE;
//	15: seven[2] = sevenF;
//	default: seven[2] = sevenDefault;
//endcase
case (`dig1)
	0 : seven[1] = seven0;
	1 : seven[1] = seven1;
	2 : seven[1] = seven2;
	3 : seven[1] = seven3;
	4 : seven[1] = seven4;
	5 : seven[1] = seven5;
	6 : seven[1] = seven6;
	7 : seven[1] = seven7;
	8 : seven[1] = seven8;
	9 : seven[1] = seven9;
	10: seven[1] = sevenA;
	11: seven[1] = sevenB;
	12: seven[1] = sevenC;
	13: seven[1] = sevenD;
	14: seven[1] = sevenE;
	15: seven[1] = sevenF;
	default: seven[1] = sevenDefault;
endcase
case (`dig0)
	0 : seven[0] = seven0;
	1 : seven[0] = seven1;
	2 : seven[0] = seven2;
	3 : seven[0] = seven3;
	4 : seven[0] = seven4;
	5 : seven[0] = seven5;
	6 : seven[0] = seven6;
	7 : seven[0] = seven7;
	8 : seven[0] = seven8;
	9 : seven[0] = seven9;
	10: seven[0] = sevenA;
	11: seven[0] = sevenB;
	12: seven[0] = sevenC;
	13: seven[0] = sevenD;
	14: seven[0] = sevenE;
	15: seven[0] = sevenF;
	default: seven[0] = sevenDefault;
endcase
end

always @(posedge OutClk)begin
	Val = seven[i];
	if(DisplayFlag)begin
	Place = select[i];
	end
	else begin
	Place = 4'b1111;
	end
	i = i + 1;
	if(i > 1)begin // only printing to the first two
		i = 0;
		end
	else begin
		i = i;
		end
end
endmodule
