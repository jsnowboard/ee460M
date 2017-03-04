module Lab4parkingMeterTop(CLK, SW0, SW1, UP, DWN, LEFT, RIGHT, seg, an);
input CLK, SW0, SW1, UP, DWN, LEFT, RIGHT;
output [3:0] an;
output [6:0] seg;
wire out1Hz, out1f2Hz, out62Hz, UPd, DWNd, LEFTd, RIGHTd, displayFlag;
wire [3:0] Thous, Hund, Tens, Ones;
wire [13:0] countOut, decOut;

//Multiple clocks
//Lab4clock c62hz(CLK, 1600000, out62Hz);
//Lab4clock c62hz(CLK, 10000, out62Hz);
//Lab4clock c1hz (CLK, 100000000, out1f2Hz);
//Lab4clock c2hz (CLK, 50000000, out1Hz);

Lab4clock c62hz(CLK, 2, out62Hz);
Lab4clock c1hz (CLK, 20, out1f2Hz);
Lab4clock c2hz (CLK, 10, out1Hz);

//Decounce and synch inputs
Lab4Debouncer updebounce(UP, UPd, CLK);
Lab4Debouncer downdebounce(DWN, DWNd, CLK);
Lab4Debouncer leftdebounce(LEFT, LEFTd, CLK);
Lab4Debouncer rightdebounce(RIGHT, RIGHTd, CLK);
//Count and decrement
Lab4counter count(decOut, SW0, SW1, UPd, LEFTd, RIGHTd, DWNd, countOut);
Lab4decrementer decrement(out1f2Hz, countOut, decOut, displayFlag);
//Convert to BCD
Lab4BinaryToBCD convert(countOut, Thous, Hund, Tens, Ones);
//Convert to 7-Segment and Output
Lab4BCDTo7Segment outToBoard(Thous, Hund, Tens, Ones, seg, an, out62Hz, displayFlag);

endmodule

