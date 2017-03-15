module Lab4Controller(r10, r205, a50, a150, a200, a500, valout, slowCLK, displayFlag);
input r10, r205, a50, a150, a200, a500, slowCLK;
output displayFlag;
output [13:0] valout;

wire df;
wire [13:0] decIn;
reg [13:0] temp;
reg plus50, plus150, plus200, plus500;

Lab4decrementer dec(slowCLK, temp, decIn, df);
Lab4counter count(temp, r10, r205, a50, a150, a200, a500, valout);

assign displayFlag = df;



//initial begin 
//	temp = 0;
//	end

//always @(a50, a150, a200, a500, r205, r10)begin
    
//    if (r10)begin
//        temp = 10;
//        end
//    else if (r205)begin
//        temp = 205;
//        end
//	else if (a50)begin
//	   temp = temp + 50;
//		end
//	else if (a150)begin
//	   temp = temp + 150;
//		end	
//	else if (a200)begin
//	   temp = temp + 200;
//		end
//	else if (a500)begin
//	   temp = temp + 500;
//		end
//	else begin
//	   temp = temp;
//		end
//end

//assign valout = (temp > 9999) ? 9999 : temp; //Final output

endmodule
