module Lab5_VGAcontroller(clk_100Mhz, sw, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);
input clk_100Mhz;
input [7:0] sw;
output Hsync, Vsync;
output [2:0] vgaRed, vgaGreen, vgaBlue;

reg [2:0] redReg, greenReg, blueReg;
wire clk_25Mhz, hsync, vsync;
wire displaySig;

integer hcount = 0, vcount = 0;

// RGB Parameters describing colors
parameter [2:0] CYAN    [2:0] = '{   0, 204, 204}; // Close to DarkTurquoise
parameter [2:0] BLACK   [2:0] = '{   0,   0,   0};
parameter [2:0] BLUE    [2:0] = '{   0,   0, 255};
parameter [2:0] BROWN   [2:0] = '{ 139,  69,  19}; // SaddleBrown technically
parameter [2:0] RED     [2:0] = '{ 255,   0,   0};
parameter [2:0] MAGENTA [2:0] = '{ 255,   0, 255}; // Fuscia matches better
parameter [2:0] YELLOW  [2:0] = '{ 255, 255,   0};
parameter [2:0] WHITE   [2:0] = '{ 255, 255, 255};

Lab4clock pixClock(clk_100Mhz,  3, clk_25Mhz);
// Outputs are latched at the 100Mhz clock edge
DFF f1(clk_100Mhz, vsync, Vsync);
DFF f2(clk_100Mhz, hsync, Hsync);
DFF f3(clk_100Mhz, redReg, vgaRed);
DFF f4(clk_100Mhz, greenReg, vgaGreen);
DFF f5(clk_100Mhz, blueReg, vgaBlue);

// Vsync and Hsync signals depends on the count value
// DOUBLE CHECK WITH BOARD: the values might be one or two off
assign vsync = ( (vcount < 494) && (vcount > 492) ) ? 0 : 1;
assign hsync = ( (hcount < 755) && (hcount > 658) ) ? 0 : 1;

// only display if in the visible region
assign displaySig = ( (hcount > 639) || (vcount > 479) ) ? 0 : 1;

always @(posedge clk_25Mhz)
begin
	// determine position on screen
	if (hcount >= 799)
	begin
	// End of line, reset hcount after retrace
		hcount <= 0;
		if (vcount >= 524)
		begin
		// Bottom of screen, reset vcount after vretrace
			vcount <= 0;
		end
		else
		begin
			vcount <= vcount + 1;
		end
	end
	else
	begin
		hcount <= hcount + 1;
	end

	if (displaySig)
	begin
		// Video output by pixel
		if (sw[0])
		begin 
			redReg   = BLACK[0];
			greenReg = BLACK[1];
			blueReg  = BLACK[2];
		end
		else if (sw[1])
		begin 
			redReg   = BLUE[0];
			greenReg = BLUE[1];
			blueReg  = BLUE[2];
		end
		else if (sw[2])
		begin 
			redReg   = BROWN[0];
			greenReg = BROWN[1];
			blueReg  = BROWN[2];
		end
		else if (sw[3])
		begin 
			redReg   = CYAN[0];
			greenReg = CYAN[1];
			blueReg  = CYAN[2];
		end
		else if (sw[4])
		begin 
			redReg   = RED[0];
			greenReg = RED[1];
			blueReg  = RED[2];
		end
		else if (sw[5])
		begin 
			redReg   = MAGENTA[0];
			greenReg = MAGENTA[1];
			blueReg  = MAGENTA[2];
		end
		else if (sw[6])
		begin 
			redReg   = YELLOW[0];
			greenReg = YELLOW[1];
			blueReg  = YELLOW[2];
		end
		else if (sw[7])
		begin 
			redReg   = WHITE[0];
			greenReg = WHITE[1];
			blueReg  = WHITE[2];
		end
		else
		begin 
			redReg   = BLACK[0];
			greenReg = BLACK[1];
			blueReg  = BLACK[2];
		end
	end
	else
	begin 
		redReg   = BLACK[0];
		greenReg = BLACK[1];
		blueReg  = BLACK[2];
	end
end


endmodule


