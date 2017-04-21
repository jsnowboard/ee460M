module Lab5_PartB(clk_100Mhz, sw, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);
input clk_100Mhz;
input[7:0] sw;
output Vsync, Hsync;
output [3:0] vgaRed, vgaGreen, vgaBlue;

Lab4clock pixClock(clk_100Mhz,  1, clk_25Mhz);

Lab5_VGAcontroller vga(clk_25Mhz, sw, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);

endmodule
