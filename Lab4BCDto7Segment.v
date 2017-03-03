module Lab4BCDTo7Segment (Thous, Hund, Tens, Ones, Val, Place, OutClk, DisplayFlag);
input OutClk, DisplayFlag;
input [3:0] Thous, Hund, Tens, Ones;
output reg [6:0] Val;
output reg [3:0] Place;

reg [6:0] seven [3:0];
//parameter seven0 = 7'b1111110, seven1 = 7'b0110000, seven2 = 7'b1101101,
//	seven3 = 7'b1111001,seven4 = 7'b0110011, seven5 = 7'b1011011, seven6 = 7'b1011111,
//	seven7 = 7'b1110000, seven8 = 7'b1111111, seven9 = 7'b1111011, sevenD = 7'b0000000;
parameter seven0 = 7'b1000000, seven1 = 7'b1111001, seven2 = 7'b0100100, 
    seven3 = 7'b0110000, seven4 = 7'b0011001, seven5 = 7'b0010010, seven6 = 7'b0000010,
    seven7 = 7'b1111000, seven8 = 7'b0000000, seven9 = 7'b0010000, sevenD = 7'b1111111;
wire [3:0] select [3:0];
integer i = 0;

assign select[0] = 4'b1110;
assign select[1] = 4'b1101;
assign select[2] = 4'b1011;
assign select[3] = 4'b0111;

//A is MSB, G is LSB
always @(Thous, Hund, Tens, Ones)begin
case (Thous)
	0 : seven[3] = seven0;
	1 : seven[3] = seven1;
	2 : seven[3] = seven2;
	3 : seven[3] = seven3;
	4 : seven[3] = seven4;
	5 : seven[3] = seven5;
	6 : seven[3] = seven6;
	7 : seven[3] = seven7;
	8 : seven[3] = seven8;
	9 : seven[3] = seven9;
	default: seven[3] = sevenD;
endcase
case (Hund)
	0 : seven[2] = seven0;
	1 : seven[2] = seven1;
	2 : seven[2] = seven2;
	3 : seven[2] = seven3;
	4 : seven[2] = seven4;
	5 : seven[2] = seven5;
	6 : seven[2] = seven6;
	7 : seven[2] = seven7;
	8 : seven[2] = seven8;
	9 : seven[2] = seven9;
	default: seven[2] = sevenD;
endcase
case (Tens)
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
	default: seven[1] = sevenD;
endcase
case (Ones)
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
	default: seven[0] = sevenD;
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
	if(i > 3)begin
		i = 0;
		end
	else begin
		i = i;
		end
end
endmodule
