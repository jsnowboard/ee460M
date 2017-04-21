`define blueCode 2'b00
`define blackCode 2'b01
`define whiteCode 2'b10
`define greenCode 2'b11
`define bottomEdge 480
`define rightEdge 640
`define topEdge 0
`define leftEdge 0
module Lab5_GameController(xCoord, yCoord, CLK, KeyIn, draw);
input [9:0] xCoord, yCoord;
input CLK;
input [7:0] KeyIn;
output reg [1:0] draw;

wire gameClk, gameClkSlow, gameClkFast;
reg speed;
reg [1:0] snake;
reg [3:0] state, prevState; // 16 states
reg [9:0] snakePosX;
reg [9:0] snakePosY;
reg [9:0] segX[4:2];
reg [9:0] segY[4:2];

Lab4clock gameClock(CLK, 10000000, gameClkSlow);
Lab4clock gameClockf(CLK,  2000000, gameClkFast);

assign gameClk = (speed) ? gameClkFast : gameClkSlow;

parameter xWid = 10, yWid = 10; // 10 pixels wide and x segments 10 pix long
integer sLength = 4; // snake is 4 segments long first (40pix)

always @ (*)
begin

	if (snake == `blackCode)
	begin
		draw <= snake;
	end
	else if ( ((xCoord >= snakePosX-xWid) && (xCoord <= snakePosX) ) &&
	     ((yCoord >= snakePosY-yWid) && (yCoord <= snakePosY) ) )
	begin
		draw <= `greenCode; // Green snake head
	end
	else if ( ((xCoord >= segX[2]-xWid) && (xCoord <= segX[2]) ) &&
             ((yCoord >= segY[2]-yWid) && (yCoord <= segY[2]) ) )
    begin
        draw <= snake;
    end
    else if ( ((xCoord >= segX[3]-xWid) && (xCoord <= segX[3]) ) &&
             ((yCoord >= segY[3]-yWid) && (yCoord <= segY[3]) ) )
    begin
        draw <= snake;
    end
    else if ( ((xCoord >= segX[4]-xWid) && (xCoord <= segX[4]) ) &&
             ((yCoord >= segY[4]-yWid) && (yCoord <= segY[4]) ) )
    begin
        draw <= snake;
    end
	else
	begin
		draw <= `whiteCode;
	end


end

always @(posedge CLK)
begin
if ((state != 6) || (KeyIn == 8'h2D) || (KeyIn == 8'h1B))
begin
	case (KeyIn)
	8'h79: // Game speed increase
	begin
	   if (state == 7)
	       speed = 1;
	   else
	       speed = speed;
	end
	8'h7B: // Game speed normal setting
	begin
       if (state == 7)
           speed = 0;
       else
           speed = speed;
	end
	8'h1B: //Start
	begin
		prevState = 1;
		state = 7; // start the game going right
	end
	8'h4D: //Pause
	begin
		prevState = (state != 6) ? state : prevState;
		state = 6;  // pause state
	end
	8'h2D: //Resume
	begin
		state = prevState;
        prevState = state;
	end
	8'h76: //ESC
	begin
		prevState = 0;
		state = 1; // 1 is escape state
	end
	8'h6B: //Left
	begin
	    if (state != 4)
	    begin
		  prevState = state;
		  state = 2; // go left or continue
		end
		else
		begin
		  prevState = prevState;
		  state = state;
		end
	end
	8'h75: // Up
	begin
	   if (state != 5)
	   begin
		  prevState = state;
		  state = 3; // go up or continue
        end
        else
        begin
          prevState = prevState;
          state = state;
        end
	end
	8'h74, 8'hE0: // Right code and additional right on the keyboard
	begin
	   if (state != 2)
	   begin
		  prevState = state;
		  state = 4; // go right or continue
        end
        else
        begin
          prevState = prevState;
          state = state;
        end
	end
	8'h72: // Down
	begin
	    if (state != 3)
	    begin
		  prevState = state;
		  state = 5; // go down or continue
        end
        else
        begin
          prevState = prevState;
          state = state;
        end
	end
	default:
	begin
		prevState = state;
		state = 4;
	end
	endcase
end
else
begin
    state = state;
    prevState = prevState;
end
	
end


always @(posedge gameClk)
begin
if( (    (snakePosX <= `rightEdge ) && (snakePosX > `leftEdge) && 
         (snakePosY <= `bottomEdge) && (snakePosY > `topEdge ) )   )
begin
	case (state)
	default: // initial state go right
	begin 
		snake <= `blueCode;
		snakePosX <= 100;
        snakePosY <= 50;
        segX[2]   <= 90;
        segX[3]   <= 80;
        segX[4]   <= 70;
        segY[2]   <= 50;
        segY[3]   <= 50;
        segY[4]   <= 50;
	end
	1: // Escape blacks out the screen
	begin
		snake = `blackCode;
		snakePosY <= 700;
		snakePosX <= 700;		
	end
	2: // go left
	begin
		snake <= `blueCode;
		snakePosX <= snakePosX - 4'd10;
		snakePosY <= snakePosY;
        segX[2] <= snakePosX;
        segX[3] <= segX[2];
        segX[4] <= segX[3];
        segY[2] <= snakePosY;
        segY[3] <= segY[2];
        segY[4] <= segY[3];
	end
	3: // go up
	begin
		snake <= `blueCode;
		snakePosY <= snakePosY - 4'd10;
		snakePosX <= snakePosX;
        segX[2] <= snakePosX;
        segX[3] <= segX[2];
        segX[4] <= segX[3];
        segY[2] <= snakePosY;
        segY[3] <= segY[2];
        segY[4] <= segY[3];
	end
	4: // go right
	begin
		snake <= `blueCode;
		snakePosX <= snakePosX + 4'd10;
		snakePosY <= snakePosY;
		segX[2] <= snakePosX;
        segX[3] <= segX[2];
        segX[4] <= segX[3];
        segY[2] <= snakePosY;
        segY[3] <= segY[2];
        segY[4] <= segY[3];
	end
	5: // go down 
	begin
		snake <= `blueCode;
		snakePosY <= snakePosY + 4'd10;
		snakePosX <= snakePosX;
        segX[2] <= snakePosX;
        segX[3] <= segX[2];
        segX[4] <= segX[3];
        segY[2] <= snakePosY;
        segY[3] <= segY[2];
        segY[4] <= segY[3];
	end
	6: // Pause
	begin
		snake <= `blueCode;
		snakePosY <= snakePosY;
		snakePosX <= snakePosX;
        segX[2]   <= segX[2];
        segX[3]   <= segX[3];
        segX[4]   <= segX[4];
        segY[2]   <= segY[2];
        segY[3]   <= segY[3];
        segY[4]   <= segY[4];
	end
	7: // start
	begin
	    snake     <= `blueCode;
    	snakePosX <= 100;
        snakePosY <= 50;
        segX[2]   <= 90;
        segX[3]   <= 80;
        segX[4]   <= 70;
        segY[2]   <= 50;
        segY[3]   <= 50;
        segY[4]   <= 50;
	end
	endcase
end
else
begin
    // Game over, need to restart
    case (state)
    1: // Escape blacks out the screen
    begin
        snake = `blackCode;
        snakePosY <= snakePosY;
        snakePosX <= snakePosX;        
    end
    7: // start
    begin
        snake     <= `blueCode;
        snakePosX <= 100;
        snakePosY <= 50;
        segX[2]   <= 90;
        segX[3]   <= 80;
        segX[4]   <= 70;
        segY[2]   <= 50;
        segY[3]   <= 50;
        segY[4]   <= 50;
    end
    default:
    begin
    snakePosX <= snakePosX;
    snakePosY <= snakePosY;
    segX[2] <= segX[2];
    segX[3] <= segX[3];
    segX[4] <= segX[4];
    segY[2] <= segY[2];
    segY[3] <= segY[3];
    segY[4] <= segY[4];
    end
    endcase
end
    
end

endmodule
