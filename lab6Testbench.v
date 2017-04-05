`define btnr 2'b01
`define btnl 2'b10
`define pushMode 2'b00
`define addMode 2'b01
`define clrMode 2'b10
`define decMode 2'b11
module lab6Testbench;

parameter N = 8;
parameter seven0 = 8'b10000000, seven1 = 8'b11110010, seven2 = 8'b01001000, 
    seven3 = 8'b01100000, seven4 = 8'b00110010, seven5 = 8'b00100100, seven6 = 8'b00000100,
    seven7 = 8'b11110000, seven8 = 8'b00000000, seven9 = 8'b00100000, sevenDefault = 8'b11111111, 
    sevenA = 8'b00010001, sevenB = 8'b00000001, sevenC = 8'b10001101, sevenD = 8'b10000001,
    sevenE = 8'b00001101, sevenF = 8'b00011101;

reg clk [1:N];
reg [1:0] mode [1:N]; // sw15 and sw14 are mode switches
reg [1:0] btns [1:N]; // button left and button right
reg [7:0] swtchs [1:N];
// Output
reg [7:0] leds [1:N];
reg [6:0] segs [1:N];
reg [3:0] an [1:N];

initial
begin
// test 1
// clear stack
mode[1]   <= `clrMode;    // Clear/Reset Mode
btns[1]   <= `btnl;       // Clear
swtchs[1] <= 8'h00;       // data doesn't matter
leds[1]   <= 8'b10000000; // Empty flag set DAR 0x00
segs[1]   <= seven0;      // DVR = 0x00
an[1]     <= 4'b1110;     // Print the lsb on 7seg
// test 1
// push 0x0F to stack
mode[1]   <= `pushMode;   // push/pop mode
btns[1]   <= `btnr;       // Push value to stack
swtchs[1] <= 8'h0F;       // 0x0F value
leds[1]   <= 8'b00000000; // no leds lit
segs[1]   <= 7'b1111111;  // no sement is lit
an[1]     <= 4'b1111;     // make sure we don't want to display anything
// test 2
// push 0x01 to stack
mode[2]   <= `pushMode;   // push/pop mode
btns[2]   <= `btnr;       // Push value to stack
swtchs[2] <= 8'h01;       // 0x01 value
leds[2]   <= 8'b00000000; // no leds lit
segs[2]   <= 7'b1111111;  // no sement is lit
an[2]     <= 4'b1111;     // make sure we don't want to display anything
// test 3
// add 0x0F and 0x01
mode[3]   <= `addMode;       // add/subtract mode
btns[3]   <= `btnr;       // add 2 most recent values on stack
swtchs[3] <= 8'h0F;       // 0x0F value not used here
leds[3]   <= 8'b00000000; // no leds lit
segs[3]   <= 7'b1111111;  // no sement is lit
an[3]     <= 4'b1111;     // make sure we don't want to display anything
// test 4
// add 0x0F and 0x01
mode[4]   <= `addMode;       // add/subtract mode
btns[4]   <= `btnr;       // add 2 most recent values on stack
swtchs[4] <= 8'h0F;       // 0x0F value not used here
leds[4]   <= 8'b00000000; // no leds lit
segs[4]   <= 7'b1111111;  // no sement is lit
an[4]     <= 4'b1111;     // make sure we don't want to display anything

top(clk, mode, btns, swtchs, leds, segs, an);


endmodule

