`define KEY keyPressed[8:1]
`define KEYUP keyPressed[19:12]
`define blueCode 2'b00
`define blackCode 2'b01
`define whiteCode 2'b10
// Top module for the snake game
module Lab5_Snake(clk_100Mhz, PS2Clk, PS2Data,
    Vsync, Hsync, vgaRed, vgaGreen, vgaBlue, Val, Place, led);
input clk_100Mhz, PS2Clk, PS2Data;
output Hsync, Vsync;
output [3:0] vgaRed, vgaGreen, vgaBlue;
output [7:0] Val;
output [3:0] Place;


wire [21:0] keyPressed;
reg [7:0] displayCode;
output reg led;
wire [1:0] color;

wire [9:0] xCoord, yCoord;

Lab5_Keyboard kb(PS2Clk, PS2Data, keyPressed);

always @(posedge PS2Clk)
begin

    if (`KEYUP == 8'hF0)
    begin
        displayCode <= `KEY;
        led <= 1;
    end
    else
    begin
        displayCode <= displayCode;
        led <= 0;
    end
end

Lab4clock c62hz  (clk_100Mhz, 10000, out62Hz);
HexTo7Segment segOut(displayCode, Val, Place, out62Hz, 1);

// VGA Display
Lab4clock clk25Mhz(clk_100Mhz, 1, clk_25Mhz);
Lab5_VGAcontroller display(clk_25Mhz, color, xCoord, yCoord, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);

Lab5_GameController gc(xCoord, yCoord, clk_100Mhz, displayCode, color);

endmodule
 