`define KEY displayCode[8:1]
`define KEYUP displayCode[19:12]
module Lab5_PartA(clk_100Mhz, PS2Clk, PS2Data, Val, Place, led);
input clk_100Mhz, PS2Data, PS2Clk;
output [7:0] Val;
output [3:0] Place;
output reg [2:0] led;

wire [21:0] displayCode;
reg [7:0] outCode;
wire kpSignal;

wire displayFlag;

assign displayFlag = kpSignal ? 1 : 0;

Lab4clock c62hz  (clk_100Mhz, 10000, out62Hz);
Lab4clock c1000hz(clk_100Mhz,  5000, out1000Hz);

Lab5_Keyboard keyboard(PS2Clk, PS2Data, displayCode);
HexTo7Segment outVal(outCode, Val, Place, out62Hz, 1);

// flasher
always @(posedge out1000Hz)
begin
    if (`KEYUP == 8'hF0)
        led[0] <= 1;
    else
        led[0] <= 0;
end

always @(posedge PS2Clk)
begin
    if (`KEYUP == 8'hF0)
        outCode <= `KEY;
end

endmodule
