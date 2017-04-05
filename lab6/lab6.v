module top(clk, mode, btns, swtchs, leds, segs, an);
  input clk;
  input[1:0] mode;
  input[1:0] btns;
  input[7:0] swtchs;
  output[7:0] leds;
  output[6:0] segs;
  output[3:0] an;

  //might need to change some of these from wires to regs
  wire cs;
  wire we;
  wire[6:0] addr;
  wire[7:0] data_out_mem;
  wire[7:0] data_out_ctrl;
  wire[7:0] data_bus;

  //MODIFY THE RIGHT HAND SIDE OF THESE TWO STATEMENTS ONLY
  assign data_bus = (we) ? data_out_ctrl : 8'bz; // 1st driver of the data bus -- tri state switches,
                       // logical function of we and data_out_ctrl

  assign data_bus = (~we) ? data_out_mem : 8'bz; // 2nd driver of the data bus -- tri state switches,
                       // logical function of we and data_out_mem


  controller ctrl(clk, cs, we, addr, data_bus, data_out_ctrl, mode,
    btns, swtchs, leds, segs, an);

  memory mem(clk, cs, we, addr, data_bus, data_out_mem);

  //add any other functions you need
  //(e.g. debouncing, multiplexing, clock-division, etc)

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

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
  output[6:0] segs;
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

  reg [6:0] SPR, DAR, prevSPR;
  wire [7:0] DVR;
  reg [7:0] temp1, temp2, prev_temp1, prev_temp2;
  reg [4:0] state, nextState;

  reg [6:0] address;
  reg[7:0] data_out; 
  reg cs;
  reg we;
 
  always @(state) 
  begin
  	we = 0;
  	data_out = 0;
  	address = SPR;
  	temp1 = prev_temp1;
  	temp2 = prev_temp2;
  	SPR = prevSPR;
  	DAR = SPR + 1;
  	case(state)
  		idle : begin

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
  			nextState = idle;
  		end
  		reset : begin
  			SPR = 7'h7f;
  			DAR = 0;
  			nextState = idle;
  		end
  		top : begin
  			DAR = SPR + 1;
  			nextState = idle;
  		end
  		inc : begin
  			DAR = DAR + 1;
  			nextState = idle;
  		end
  		dec : begin
  			DAR = DAR - 1;
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
  			data_out = temp2 + temp1;
  			address = SPR;
  			we = 1;
  			nextState = idle;
  		end
  		add2 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readSecondAdd;
  		end
  		sub1 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readFirstAdd;
  		end
  		readFirstSub : begin
  			temp1 = data_in;
  			nextState = sub2;
  		end
  		// Make sure this can all be done in same state 
  		readSecondSub : begin
  			temp2 = data_in;
  			data_out = temp2 - temp1;
  			address = SPR;
  			we = 1;
  			nextState = idle;
  		end
  		sub2 : begin
  			address = SPR + 1;
  			SPR = SPR + 1;
  			nextState = readSecondSub;
  		end

  	endcase
  end

  always @(negedge clk)
  begin
  	prevSPR <= SPR;
  	temp1 <= prev_temp1;
  	temp2 <= prev_temp2;
  	case(mode) 
  		0 : begin
  			if(btns[1]) begin
  				state <= push;
  			end
  			else if(btns[0]) begin
  				state <= pop;
  			end
  			else state <= nextState;
  		end
  		1 : begin
  			if(btns[1]) begin
  				state <= sub1;
  			end
  			else if(btns[0]) begin
  				state <= add1;
  			end
  			else state <= nextState;
  		end
  		2 : begin
  			if(btns[1]) begin
  				state <= reset;
  			end
  			else if(btns[0]) begin
  				state <= top;
  			end
  			else state <= nextState;
  		end
  		3 : begin
  			if(btns[1]) begin
  				state <= dec;
  			end
  			else if(btns[0]) begin
  				state <= inc;
  			end
  			else state <= nextState;
  		end
  	endcase
  end

assign DVR = (SPR == 7'h7f) ? 0 : data_in;
assign leds[7] = (SPR == 7'h7f) ? 1 : 0;
assign leds[6:0] = DAR;

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