//Uncomment the following line for Modelsim simulation
//`define SIM
`define blueCode 2'b00
`define blackCode 2'b01
`define whiteCode 2'b10
`define greenCode 2'b11
module Lab5_VGAcontroller(clk_25Mhz, color, xCoord, yCoord, 
		Vsync, Hsync, vgaRed, vgaGreen, vgaBlue);
input clk_25Mhz;
input [1:0] color;
output [9:0] xCoord, yCoord;
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
parameter [3:0] GREEN   [2:0] = '{  0, 15,  0};
`else
parameter [3:0] CYAN    [2:0] = {  0, 12, 12}; // Close to DarkTurquoise
parameter [3:0] BLACK   [2:0] = {  0,  0,  0};
parameter [3:0] BLUE    [2:0] = {  0,  0, 15};
parameter [3:0] BROWN   [2:0] = {  8,  4,  1}; // SaddleBrown technically
parameter [3:0] RED     [2:0] = { 15,  0,  0};
parameter [3:0] MAGENTA [2:0] = { 15,  0, 15}; // Fuscia matches better
parameter [3:0] YELLOW  [2:0] = { 15, 15,  0};
parameter [3:0] WHITE   [2:0] = { 15, 15, 15};
parameter [3:0] GREEN   [2:0] = {  0, 15,  0};
`endif

// Outputs are latched at the 100Mhz clock edge
DFF f1(clk_25Mhz, vsync, Vsync);
DFF f2(clk_25Mhz, hsync, Hsync);
DFF4 f3(clk_25Mhz, redReg, vgaRed);
DFF4 f4(clk_25Mhz, greenReg, vgaGreen);
DFF4 f5(clk_25Mhz, blueReg, vgaBlue);

assign xCoord = hcount;
assign yCoord = vcount;

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
		case (color)
		`blueCode:
		begin
			redReg   <= BLUE[2];
			greenReg <= BLUE[1];
			blueReg  <= BLUE[0];
		end
		`blackCode:
		begin
			redReg   <= BLACK[2];
			greenReg <= BLACK[1];
			blueReg  <= BLACK[0];
		end
		`greenCode:
		begin
		    redReg   <= GREEN[2];
            greenReg <= GREEN[1];
            blueReg  <= GREEN[0];
        end
		default:
		begin
			redReg   <= WHITE[2];
			greenReg <= WHITE[1];
			blueReg  <= WHITE[0];
		end
		endcase
	end
	else
	begin 
		redReg   <= 0;
		greenReg <= 0;
		blueReg  <= 0;
	end
end


endmodule


