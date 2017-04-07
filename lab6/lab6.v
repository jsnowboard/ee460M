module top(clk, mode, btns, sw, led, seven, an);
  input clk;
  input[1:0] mode;
  input[1:0] btns;
  input[7:0] sw;
  output[7:0] led;
  output[7:1] seven;
  output[3:0] an;

  //might need to change some of these from wires to regs
  wire cs;
  wire we;
  wire[6:0] addr;
  wire[7:0] data_out_mem;
  wire[7:0] data_out_ctrl;
  wire[7:0] data_bus;
  wire [1:0] btns_debounced;

  //MODIFY THE RIGHT HAND SIDE OF THESE TWO STATEMENTS ONLY
  assign data_bus = (we) ? data_out_ctrl : 8'bz; // 1st driver of the data bus -- tri state switches,
                       // logical function of we and data_out_ctrl

  assign data_bus = (~we) ? data_out_mem : 8'bz; // 2nd driver of the data bus -- tri state switches,
                       // logical function of we and data_out_mem


  controller ctrl(clk, cs, we, addr, data_bus, data_out_ctrl, mode,
    btns_debounced, sw, led, seven, an);

  memory mem(clk, cs, we, addr, data_bus, data_out_mem);
  
  Debounce D(clk, btns[1], btns[0], btns_debounced[1], btns_debounced[0]);

  //add any other functions you need
  //(e.g. debouncing, multiplexing, clock-division, etc)

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
`define BtnL btns[0]
`define BtnR btns[1]
module controller(clk, cs, we, address, data_in, data_out, mode, btns, swtchs, leds, segs, an);
  input clk;
  output cs;
  output we;
  output[6:0] address;
  input[7:0] data_in;
  output[7:0] data_out;
  input[1:0] mode;
  input[1:0] btns;
  input[7:0] swtchs;
  output[7:0] leds;
  output[7:1] segs;
  output[3:0] an;


  parameter idle = 0;
  parameter push = 1;
  parameter pop = 2;
  parameter reset = 3;
  parameter top = 4;
  parameter inc = 5;
  parameter dec = 6;
  parameter add1 = 7;
  parameter readFirstAdd = 8;
  parameter readSecondAdd = 9;
  parameter add2 = 10;
  parameter sub1 = 11;
  parameter sub2 = 12;
  parameter readFirstSub = 13;
  parameter readSecondSub = 14;
  parameter writeAdd = 15;
  parameter writeSub = 16;

  reg [6:0] SPR, DAR, prevSPR, prevDAR;
  wire [7:0] DVR;
  reg [7:0] temp1, temp2, prev_temp1, prev_temp2;
  reg [4:0] state, nextState;

  reg [6:0] address;
  reg[7:0] data_out; 
  reg cs;
  reg we;
  
  wire sevenSegCLK, slowCLK;
	
initial begin
state = 0;
nextState = 0;
SPR = 7'h7f;
DAR = 0;
prevSPR = 7'h7f;
prevDAR = 0;
temp1 = 0;
temp2 = 0;
end
  
  always @(state) 
  begin
    cs = 1;
    nextState = 0;
  	we = 0;
  	data_out = 0;
  	SPR = prevSPR;
    DAR = prevDAR;
  	address = DAR;
  	temp1 = prev_temp1;
  	temp2 = prev_temp2;
  	
  	case(state)
  		idle : begin
            nextState = idle;
  		end
  		push : begin
  			we = 1;
  			data_out = swtchs;
  			address = SPR;
  			DAR = SPR;
  			SPR = SPR - 1;
  			nextState = idle;
  		end
  		pop : begin
  			we = 0;
  			SPR = SPR + 1;
  			DAR = SPR + 1;
  			address = DAR;
  			nextState = idle;
  		end
  		reset : begin
  			SPR = 7'h7f;
  			DAR = 0;
  			nextState = idle;
  		end
  		top : begin
  			DAR = SPR + 1;
  			address = DAR;
  			nextState = idle;
  		end
  		inc : begin
  			DAR = DAR + 1;
  			address = DAR;
  			nextState = idle;
  		end
  		dec : begin
  			DAR = DAR - 1;
  			address = DAR;
  			nextState = idle;
  		end
  		add1 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readFirstAdd;
  		end
  		readFirstAdd : begin
  			temp1 = data_in;
  			nextState = add2;
  		end
  		// Make sure this can all be done in same state 
  		readSecondAdd : begin
  			temp2 = data_in;	
  			nextState = writeAdd;
  		end
  		add2 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readSecondAdd;
  		end
  		writeAdd : begin
  		    data_out = temp2 + temp1;
            address = SPR;
            SPR = SPR - 1;
            we = 1;
            DAR = SPR + 1;
            nextState = idle;
  		end
  		sub1 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readFirstSub;
  		end
  		readFirstSub : begin
  			temp1 = data_in;
  			nextState = sub2;
  		end
  		// Make sure this can all be done in same state 
  		readSecondSub : begin
  			temp2 = data_in;
  			nextState = writeSub;
  		end
  		sub2 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readSecondSub;
  		end
  		writeSub : begin
  		    data_out = temp1 - temp2;
            address = SPR;
            we = 1;
            SPR = SPR - 1;
            DAR = SPR + 1;
            nextState = idle;
  		end

  	endcase
  end

  always @(negedge slowCLK)
  begin
  	prevSPR <= SPR;
  	prevDAR <= DAR;
  	prev_temp1 <= temp1;
  	prev_temp2 <= temp2;
  	case(mode) 
  		0 : begin
  			if(`BtnL) begin
  				state <= pop;
  			end
  			else if(`BtnR) begin
  				state <= push;
  			end
  			else state <= nextState;
  		end
  		1 : begin
  			if(`BtnL) begin
  				state <= sub1;
  			end
  			else if(`BtnR) begin
  				state <= add1;
  			end
  			else state <= nextState;
  		end
  		2 : begin
  			if(`BtnL) begin
  				state <= reset;
  			end
  			else if(`BtnR) begin
  				state <= top;
  			end
  			else state <= nextState;
  		end
  		3 : begin
  			if(`BtnL) begin
  				state <= dec;
  			end
  			else if(`BtnR) begin
  				state <= inc;
  			end
  			else state <= nextState;
  		end
  	endcase
  end

assign DVR = (SPR == 7'h7f) ? 0 : data_in;
assign leds[7] = (SPR == 7'h7f) ? 1 : 0;
assign leds[6:0] = DAR;
assign an[2] = 1;
assign an[3] = 1;

clockDivider C2(28'd2500000, clk, slowCLK);
clockDivider C(28'd250000, clk, sevenSegCLK);
SevenSeg_Display S(sevenSegCLK, DVR[3:0], DVR[7:4], an[0], an[1], segs);

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module memory(clock, cs, we, address, data_in, data_out);
  //DO NOT MODIFY THIS MODULE
  input clock;
  input cs;
  input we;
  input[6:0] address;
  input[7:0] data_in;
  output[7:0] data_out;

  reg[7:0] data_out;

  reg[7:0] RAM[0:127];

  always @ (negedge clock)
  begin
    if((we == 1) && (cs == 1))
      RAM[address] <= data_in[7:0];

    data_out <= RAM[address];
  end
endmodule

module Debounce(CLK,BtnL, BtnR, BtnL_sync, BtnR_sync);

input CLK, BtnL, BtnR;
output BtnL_sync, BtnR_sync;

reg BtnL_A, BtnL_B, BtnL_C, BtnR_A, BtnR_B, BtnR_C;
wire slowCLK;

always @(posedge slowCLK)
begin
	BtnL_A <= BtnL;
	BtnL_B <= BtnL_A;
	BtnL_C <= BtnL_B;

	BtnR_A <= BtnR;
	BtnR_B <= BtnR_A;
	BtnR_C <= BtnR_B;
    
end

clockDivider C(28'd2500000, CLK, slowCLK);

assign BtnL_sync = ~BtnL_C & BtnL_B;
assign BtnR_sync = ~BtnR_C & BtnR_B;

endmodule

module SevenSeg_Display(CLK, digit1, digit2, AN0, AN1, seven);

input [3:0] digit1, digit2;
input CLK;
output AN0, AN1;
output [7:1] seven;

reg sevenSeg_state, sevenSeg_nextState;
reg [3:0] binary;
reg AN0, AN1;

always @(sevenSeg_state or digit1 or digit2)
begin
    AN0 = 1;
    AN1 = 1;
	sevenSeg_nextState = 0;
	case(sevenSeg_state)
		0 : begin
			AN0 = 0;
			sevenSeg_nextState = 1;
			binary = digit1;
		end
		1 : begin
		    AN1 = 0;
			sevenSeg_nextState = 0;
			binary = digit2;
		end
		default : begin
		    sevenSeg_nextState = 0;
		    binary = digit1;
		end
	endcase
end

always @(posedge CLK)
begin
	sevenSeg_state <= sevenSeg_nextState;
end

binary_seven B(binary, seven);

endmodule


module binary_seven (binary, seven);
	input [3:0] binary;
	output[7:1] seven;
	reg [7:1] seven;
	always @(binary)
	begin
 		case (binary)
 			4'b0000 : seven = 7'b0000001 ;
 			4'b0001 : seven = 7'b1001111 ;
 			4'b0010 : seven = 7'b0010010 ;
 			4'b0011 : seven = 7'b0000110 ;
 			4'b0100 : seven = 7'b1001100 ;
 			4'b0101 : seven = 7'b0100100 ;
 			4'b0110 : seven = 7'b0100000 ;
 			4'b0111 : seven = 7'b0001111 ;
 			4'b1000 : seven = 7'b0000000 ;
 			4'b1001 : seven = 7'b0001100 ;
			4'b1010 : seven = 7'b0001000 ;
			4'b1011 : seven = 7'b1100000 ;
			4'b1100 : seven = 7'b0110001 ;
			4'b1101 : seven = 7'b1000010 ;
			4'b1110 : seven = 7'b0110000 ;
			4'b1111 : seven = 7'b0111000 ;
 			default : seven = 7'b0000001 ;
 		endcase
 	end
endmodule
