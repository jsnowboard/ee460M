module DFF(Clk, D, Q);
input D, Clk;
output reg Q;

always @(posedge Clk)begin
Q = D;
end
endmodule

module DFF4(Clk, D, Q);
input Clk;
input [3:0] D;
output reg [3:0] Q;

always @(posedge Clk)begin
Q = D;
end
endmodule
