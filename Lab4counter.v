module Lab4counter(val, r10, r205, a50, a150, a200, a500, valout);
input [13:0] val;
input r10, r205, a50, a150, a200, a500;
output [13:0] valout;

reg [13:0] intVal;

initial
begin
	intVal <= 0;
end

//always @(val)
//begin
//	// val contains the decremented value
//	intVal <= val;
//end

always @(val, r10, r205, a50, a150, a200, a500)
begin
	if (r10)
	begin
		intVal <= 10;
	end
	else if (r205)
	begin
		intVal <= 205;
	end
	else if (a50)
	begin
		intVal <= val + 50;
	end
	else if (a150)
	begin
		intVal <= val + 150;
	end
	else if (a200)
	begin
		intVal <= val + 200;
	end
	else if (a500)
	begin
		intVal <= val + 500;
	end
	else
	begin
		intVal <= val;
	end
end

assign valout = (intVal >= 9999) ? 9999 : intVal;

endmodule 
