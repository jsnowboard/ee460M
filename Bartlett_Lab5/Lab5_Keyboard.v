`define PARBIT scanCode [1]
`define PARVAL scanCode[2]^scanCode[3]^scanCode[4]^scanCode[5]^scanCode[6]^scanCode[7]^scanCode[8]^scanCode[9]
module Lab5_Keyboard(PS2Clk, PS2Data, keyPressed);
input PS2Clk, PS2Data;
output reg [21:0] keyPressed;


always @(negedge PS2Clk)
begin
keyPressed <= keyPressed >> 1;
keyPressed[21] <= PS2Data;
end

endmodule
