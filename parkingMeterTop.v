module parkingMeterTop(CLK, SW0, SW1, UP, DWN, LEFT, RIGHT, sevenSeg);
input CLK, SW0, SW1, UP, DWN, LEFT, RIGHT;
output [3:0] sevenSeg;

reg [13:0] decOut, valOut;
reg out1Hz, out1f2Hz, out62Hz;

clock c62hz(CLK, 1600000, out62Hz);
clock c1hz (CLK, 100000000, out1f2Hz);
clock c2hz (CLK, 50000000, out1Hz);

decrementer dec(CLK, valOut, decOut);
counter value(decOut, SW0, SW1, UP, LEFT, RIGHT, DOWN, valOut);


endmodule
