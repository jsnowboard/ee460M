module Lab4clock(fastCLK, fastCounter, slowCLK);
input fastCLK;
input [31:0] fastCounter;
output reg slowCLK;

reg [31:0] counter;

//parameter oneKHz = 100000, sixtyTwoPFiveHZ = 1600000;

initial
begin
	counter = 0;
	slowCLK = 0;
end

always @(posedge fastCLK)
begin
	if (counter >= fastCounter)
	begin
		slowCLK <= ~slowCLK;
		counter <= 0;
	end
	else
	begin
		slowCLK <= slowCLK;
		counter <= counter + 1;
	end
end

endmodule
