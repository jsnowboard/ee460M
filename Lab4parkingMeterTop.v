module Lab4parkingMeterTop(CLK, SW0, SW1, UP, DWN, LEFT, RIGHT, seg, an);
input CLK, SW0, SW1, UP, DWN, LEFT, RIGHT;
output [3:0] an;
output [6:0] seg;
wire out1Hz, out1f2Hz, out62Hz, UPd, DWNd, LEFTd, RIGHTd, displayFlag;
wire [3:0] Thous, Hund, Tens, Ones;
wire [13:0] contOut;
//wire [3:0] an_temp;

//Multiple clocks
//Lab4clock c62hz(CLK, 1600000, out62Hz);
Lab4clock c62hz(CLK, 10000, out62Hz);
Lab4clock clocker(CLK, 50000000, slowCLK);
//Lab4clock c1hz (CLK, 50000000, out1f2Hz);
//Lab4clock c2hz (CLK, 25000000, out1Hz);

//Decounce and synch inputs
//Lab4Debouncer updebounce(UP, UPd, CLK);
//Lab4Debouncer downdebounce(DWN, DWNd, CLK);
//Lab4Debouncer leftdebounce(LEFT, LEFTd, CLK);
//Lab4Debouncer rightdebounce(RIGHT, RIGHTd, CLK);
//Count and decrement
//Lab4counter count(decOut, SW0, SW1, UP, LEFT, RIGHT, DWN, countOut);
Lab4Controller cont(SW0, SW1, UP, LEFT, RIGHT, DWN, contOut, slowCLK, displayFlag);
//Lab4decrementer decrement(out1f2Hz, countOut, decOut, displayFlag);
//Convert to BCD
Lab4BinaryToBCD convert(contOut, Thous, Hund, Tens, Ones);
//Convert to 7-Segment and Output
Lab4BCDTo7Segment outToBoard(Thous, Hund, Tens, Ones, seg, an, out62Hz, displayFlag);
// Flash on for one clock pulse and off for the next
//Lab4Flasher flash(out1Hz, countOut, an_temp, an);
endmodule


