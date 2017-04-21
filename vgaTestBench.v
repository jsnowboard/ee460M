module vgaTestBench;

parameter N = 8; // change mayb
parameter M = 8;

reg clk_100Mhz;
reg Vsync [1:N];
reg Hsync [1:M];
reg [7:0] sw [1:N];
reg [3:0] vgaRed[1:N];
reg [3:0] vgaGreen[1:N];
reg [3:0] vgaBlue[1:N];

parameter integer m [1:M] = {0, 639, 640, 658, 659, 755, 756, 799};
parameter integer n [1:N] = {0, 479, 480, 492, 493, 494, 495, 524);
integer mind = 0, nind = 0;
integer mcount = 0;
integer ncount = 0;

Lab5_VGAcontroller vcontrol(clk_100Mhz, sw, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);

initial
begin
// inputs blue screen
sw[1] = 8'b00000010;
sw[2] = 8'b00000010;
sw[3] = 8'b00000010;
sw[4] = 8'b00000010;
sw[5] = 8'b00000010;
sw[6] = 8'b00000010;
sw[7] = 8'b00000010;
sw[8] = 8'b00000010;
// outputs
Hsync[1] = 1; // @0
Hsync[2] = 1; // 639
Hsync[3] = 1; // @640
Hsync[4] = 1; // @658
Hsync[5] = 0; // @659
Hsync[6] = 0; // @755
Hsync[7] = 1; // @756
Hsync[8] = 1; // @799

Vsync[1] = 1; // @0
Vsync[2] = 1; // @479
Vsync[3] = 1; // @480
Vsync[4] = 1; // @492
Vsync[5] = 0; // @493
Vsync[6] = 0; // @494
Vsync[7] = 1; // @495
Vsync[8] = 1; // @524

end

endmodule
