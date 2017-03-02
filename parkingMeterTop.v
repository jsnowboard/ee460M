module parkingMeterTop(CLK, SW0, SW1, UP, DWN, LEFT, RIGHT, sevenSeg);
input CLK, SW0, SW1, UP, DWN, LEFT, RIGHT;
output [3:0] sevenSeg;

reg [13:0] decOut, valOut;

decrementer dec(CLK, valOut, decOut);
counter value(decOut, SW0, SW1, UP, LEFT, RIGHT, DOWN, valOut);


endmodule
