module Lab4decrementer(CLK, valOut, decOut, displayFlag);
input CLK;
input [13:0] valOut;
output reg [13:0] decOut;
output reg displayFlag;

//reg [2:0] counter;

//initial
//begin
//    counter = 0;
//end

always @(posedge CLK)
begin
//    counter = counter +1;
	decOut = (valOut > 0) ? valOut-1: valOut;
	if (decOut <= 200)begin
//    	if (decOut %)begin
//            counter = 0;
//            end
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
