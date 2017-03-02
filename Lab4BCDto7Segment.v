module Lab4BCDTo7Segment (Thous, Hund, Tens, Ones, Val, Place, OutClk, DisplayFlag);
input OutClk, DisplayFlag;
input [3:0] Thous, Hund, Tens, Ones;
output reg [6:0] Val;
output reg [3:0] Place;

reg [6:0] seven [3:0];
parameter select = {4'b0111, 4'b1011, 4'b1101, 4'b1110, 4'b1111};
integer i;


//A is MSB, G is LSB
always @(Thous, Hund, Tens, Ones)begin
case (Thous)
	0 : seven[3] = 7'b0000001;
	1 : seven[3] = 7'b1001111;
	2 : seven[3] = 7'b0010010;
	3 : seven[3] = 7'b0000110;
	4 : seven[3] = 7'b1001100;
	5 : seven[3] = 7'b0100100;
	6 : seven[3] = 7'b0100000;
	7 : seven[3] = 7'b0001111;
	8 : seven[3] = 7'b0000000;
	9 : seven[3] = 7'b0000100;
	default: seven[3] = 7'b1111111;
endcase
case (Hund)
	0 : seven[2] = 7'b0000001;
	1 : seven[2] = 7'b1001111;
	2 : seven[2] = 7'b0010010;
	3 : seven[2] = 7'b0000110;
	4 : seven[2] = 7'b1001100;
	5 : seven[2] = 7'b0100100;
	6 : seven[2] = 7'b0100000;
	7 : seven[2] = 7'b0001111;
	8 : seven[2] = 7'b0000000;
	9 : seven[2] = 7'b0000100;
	default: seven[2] = 7'b1111111;
endcase
case (Tens)
	0 : seven[1] = 7'b0000001;
	1 : seven[1] = 7'b1001111;
	2 : seven[1] = 7'b0010010;
	3 : seven[1] = 7'b0000110;
	4 : seven[1] = 7'b1001100;
	5 : seven[1] = 7'b0100100;
	6 : seven[1] = 7'b0100000;
	7 : seven[1] = 7'b0001111;
	8 : seven[1] = 7'b0000000;
	9 : seven[1] = 7'b0000100;
	default: seven[1] = 7'b1111111;
endcase
case (Ones)
	0 : seven[0] = 7'b0000001;
	1 : seven[0] = 7'b1001111;
	2 : seven[0] = 7'b0010010;
	3 : seven[0] = 7'b0000110;
	4 : seven[0] = 7'b1001100;
	5 : seven[0] = 7'b0100100;
	6 : seven[0] = 7'b0100000;
	7 : seven[0] = 7'b0001111;
	8 : seven[0] = 7'b0000000;
	9 : seven[0] = 7'b0000100;
	default: seven[0] = 7'b1111111;
endcase
end
always @(posedge OutClk)begin
	i = i + 1;
	if(i > 3)begin
		i = 0;
		end
	else begin
		i = i;
		end
	Val = seven[i];
	if(DisplayFlag)begin
	Place = select[i];
	end
	else begin
	Place = 4'b1111;
	end
end
endmodule

