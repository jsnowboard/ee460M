module Lab4Flasher(CLK, num, val, valOut);
input CLK;
input [13:0] num;
input [3:0] val;
output reg [3:0] valOut;

integer counter = 0;

always @(posedge CLK)
begin
counter <= counter + 1;
	if ((num == 0) && (counter%2))
	begin
	valOut <= val;
	end
	else if (num > 0)
	begin
	valOut <= val;
	end
	else
	begin
	valOut <= 4'b1111;
	end
end

endmodule
