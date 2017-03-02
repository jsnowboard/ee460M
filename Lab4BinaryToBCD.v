module Lab4BinaryToBCD (Binary, Thous, Hund, Tens, Ones);
input [13:0]Binary;
output [3:0]Thous, Hund, Tens, Ones;

reg [13:0] binary;
reg [3:0] thous, hund, tens, ones;

integer i;

always @(Binary)begin
binary = Binary;
thous = 0;
hund = 0;
tens = 0;
ones = 0;
for (i = 0; i < 14; i = i + 1) begin
	if (ones > 4)begin
		ones = ones + 3;
		end
	else begin	
		ones = ones;
		end
	if (tens > 4)begin
		tens = tens + 3;
		end
	else begin
		tens = tens;
		end
	if (hund > 4)begin
		hund = hund + 3;
		end
	else begin
		hund = hund;
		end
	if (thous > 4)begin
		thous = thous + 3;
		end
	else begin
		thous = thous;
		end
thous = {thous[2:0], hund[3]};
hund = {hund[2:0], tens[3]};
tens = {tens[2:0], ones[3]};
ones = {ones[2:0], binary[13]};
binary = binary << 1;
end
end
assign Thous = thous;
assign Hund = hund;
assign Tens = tens;
assign Ones = ones;
endmodule




