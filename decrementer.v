module Lab4decrementer(CLK, valOut, decOut, displayFlag);
input CLK;
input [13:0] valOut;
output reg [13:0] decOut;
output reg displayFlag;

always @(posedge CLK)
begin
	decOut = (valOut > 0) ? valOut-1: valOut;
	if (decOut <= 200)begin
		if ((decOut % 2) == 1)begin
			displayFlag = 0;
			end
		else begin
			displayFlag = 1;
			end
		end
	else begin
		displayFlag = 1;
		end
end

endmodule
