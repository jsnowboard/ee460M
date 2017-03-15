module DFF(Clk, D, Q);
input D, Clk;
output reg Q;

always @(posedge Clk)begin
Q = D;
end
endmodule
