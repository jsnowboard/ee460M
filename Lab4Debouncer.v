module Lab4DFF(D, Q, Qp, Clk);
input D, Clk;
output reg Q, Qp;
always @(posedge Clk)begin
Q = D;
Qp = ~D;
end
endmodule

module Lab4Debouncer (In, Out, Clk);
input In, Clk;
output reg Out;
wire oneout, oneoutp, twoout, twooutp, threeout, threeoutp;
reg State;

initial begin
	State = 1'b0;
	Out = 1'b0;
	end

Lab4DFF FF1(In, oneout, oneoutp, Clk);
Lab4DFF FF2(oneout, twoout, twooutp, Clk);
//Lab4DFF FF3(twoout, threeout, threeoutp, Clk);
//assign Out = threeoutp&&twoout;

always @(posedge Clk)begin
case (State)
	1'b0:begin
	if(twoout == 1)begin
		State = 1;
		Out = 1;
		end
	else begin
		State = 0;
		Out = 0;
		end
	end
	1'b1:begin
	if(twoout == 1)begin
		State = 1;
		Out = 0;
		end
	else begin	
		State = 0;
		Out = 0;
		end
	end
	default:begin
		State = State;
		Out = Out;
		end
endcase
end
endmodule




