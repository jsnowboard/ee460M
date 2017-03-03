module Lab4Flasher(CLK, val, valOut);
input CLK;
input [3:0] val;
output reg [3:0] valOut;

integer counter = 0;

always @(posedge CLK)
begin
counter <= counter + 1;
	if (counter%2)
	begin
	valOut <= val;
	end
	else 
	begin
	valOut <= 4'b1111;
	end
end

endmodule
