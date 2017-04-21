`define KEY scanCode [9:2]
`define PARBIT scanCode [1]
`define PARVAL scanCode[2]^scanCode[3]^scanCode[4]^scanCode[5]^scanCode[6]^scanCode[7]^scanCode[8]^scanCode[9]
module Lab5_Keyboard(PS2Clk, PS2Data, keyPressed, kpSignal);
input PS2Clk, PS2Data;
output reg [7:0] keyPressed;
output kpSignal;

reg [10:0] scanCode;
reg send, transmissionComplete, strobe_100ms;

reg start, stop;
integer bitcount=0;
reg [10:0] state;
wire[7:0] key;

assign key = `KEY;

initial
begin
	state = 0;
	scanCode = 0;
	transmissionComplete = 0;
	strobe_100ms = 0;
	send = 0;
end

always @(negedge PS2Clk)
begin
	scanCode <= {scanCode<<1, PS2Data};
	case (state)
	0: 
	begin
		transmissionComplete <= 0;
		if (PS2Data == 0)
		begin
			bitcount <= bitcount + 1;
			state <= 1;
			scanCode <= {scanCode,PS2Data};
		end
		else
		begin
			bitcount <= 0;
			state <= 0;
			scanCode <= scanCode;
		end
	end
	1:
	begin
		if (bitcount<10)
		begin
			bitcount <= bitcount + 1;
			state <= 1;
			scanCode <= {scanCode, PS2Data};
		end
		else
		begin
			bitcount <= 0;
			state <= 2;
			scanCode <= scanCode;
		end
	end
	2: //all data has been transmitted
	begin
		state <= 0;
		transmissionComplete <= 1;
	end
	endcase
end

always @(transmissionComplete)
begin
	if (transmissionComplete)
	begin
		if (send)
		begin
			strobe_100ms <= 1;
			keyPressed <= `KEY;
			send <= 0;
		end
		else if (`KEY == 8'hF0)
		begin
			//keyUp so next input is key down code
			strobe_100ms <= 0;
			keyPressed <= keyPressed;
			send <= 1;
		end
		else
		begin
			strobe_100ms <= 0;
			keyPressed <= keyPressed;
			send = 0;
		end
	end
	else
	begin
		strobe_100ms <= strobe_100ms;
		keyPressed <= keyPressed;
		send <= send;
	end
end


endmodule
