module decrementer(CLK, valOut, decOut);
input CLK;
input [13:0] valOut;
output reg [13:0] decOut;

always @(posedge CLK)
begin
	decOut = (valOut > 0) ? valOut-1: valOut;
end

endmodule
