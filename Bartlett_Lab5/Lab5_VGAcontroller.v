//Uncomment the following line for Modelsim simulation
// `define SIM
module Lab5_VGAcontroller(clk_25Mhz, sw, Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);
input clk_25Mhz;
input [7:0] sw;
output Hsync, Vsync;
output [3:0] vgaRed, vgaGreen, vgaBlue;

reg [3:0] redReg, greenReg, blueReg;
wire hsync, vsync;
wire displaySig;

integer hcount = 0, vcount = 0;

`ifdef SIM
parameter [3:0] CYAN    [2:0] = '{  0, 12, 12}; // Close to DarkTurquoise
parameter [3:0] BLACK   [2:0] = '{  0,  0,  0};
parameter [3:0] BLUE    [2:0] = '{  0,  0, 15};
parameter [3:0] BROWN   [2:0] = '{  8,  4,  1}; // SaddleBrown technically
parameter [3:0] RED     [2:0] = '{ 15,  0,  0};
parameter [3:0] MAGENTA [2:0] = '{ 15,  0, 15}; // Fuscia matches better
parameter [3:0] YELLOW  [2:0] = '{ 15, 15,  0};
parameter [3:0] WHITE   [2:0] = '{ 15, 15, 15};
`else
parameter [3:0] CYAN    [2:0] = {  0, 12, 12}; // Close to DarkTurquoise
parameter [3:0] BLACK   [2:0] = {  0,  0,  0};
parameter [3:0] BLUE    [2:0] = {  0,  0, 15};
parameter [3:0] BROWN   [2:0] = {  8,  4,  1}; // SaddleBrown technically
parameter [3:0] RED     [2:0] = { 15,  0,  0};
parameter [3:0] MAGENTA [2:0] = { 15,  0, 15}; // Fuscia matches better
parameter [3:0] YELLOW  [2:0] = { 15, 15,  0};
parameter [3:0] WHITE   [2:0] = { 15, 15, 15};
`endif
// Outputs are latched at the 100Mhz clock edge
DFF f1(clk_25Mhz, vsync, Vsync);
DFF f2(clk_25Mhz, hsync, Hsync);
DFF4 f3(clk_25Mhz, redReg, vgaRed);
DFF4 f4(clk_25Mhz, greenReg, vgaGreen);
DFF4 f5(clk_25Mhz, blueReg, vgaBlue);

// Vsync and Hsync signals depends on the count value
// DOUBLE CHECK WITH BOARD: the values might be one or two off
assign vsync = ( (vcount <= 494) && (vcount >= 493) ) ? 0 : 1;
assign hsync = ( (hcount <= 755) && (hcount >= 659) ) ? 0 : 1;

// only display if in the visible region
assign displaySig = ( (hcount >= 640) || (vcount >= 480) ) ? 0 : 1;

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
			redReg   <= BLACK[2];
			greenReg <= BLACK[1];
			blueReg  <= BLACK[0];
		end
		else if (sw[1])
		begin 
			redReg   <= BLUE[2];
			greenReg <= BLUE[1];
			blueReg  <= BLUE[0];
		end
		else if (sw[2])
		begin 
			redReg   <= BROWN[2];
			greenReg <= BROWN[1];
			blueReg  <= BROWN[0];
		end
		else if (sw[3])
		begin 
			redReg   <= CYAN[2];
			greenReg <= CYAN[1];
			blueReg  <= CYAN[0];
		end
		else if (sw[4])
		begin 
			redReg   <= RED[2];
			greenReg <= RED[1];
			blueReg  <= RED[0];
		end
		else if (sw[5])
		begin 
			redReg   <= MAGENTA[2];
			greenReg <= MAGENTA[1];
			blueReg  <= MAGENTA[0];
		end
		else if (sw[6])
		begin 
			redReg   <= YELLOW[2];
			greenReg <= YELLOW[1];
			blueReg  <= YELLOW[0];
		end
		else if (sw[7])
		begin 
			redReg   <= WHITE[2];
			greenReg <= WHITE[1];
			blueReg  <= WHITE[0];
		end
		else
		begin 
			redReg   <= 0;
			greenReg <= 0;
			blueReg  <= 0;
		end
	end
	else
	begin 
		redReg   <= 0;
		greenReg <= 0;
		blueReg  <= 0;
	end
end


endmodule


