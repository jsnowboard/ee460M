module Complete_MIPS(SW, BTN, CLK, RST, A_Out, D_Out, AN, seven);
  // Will need to be modified to add functionality
  input CLK;
  input RST;
  input [1:0] BTN;
  input [2:0] SW;
  output A_Out, D_Out;
  output [3:0] AN;
  output [7:1] seven;

  wire CS, WE;
  wire [6:0] ADDR;
  wire [31:0] Mem_Bus;

  MIPS CPU(SW, BTN, CLK, RST, CS, WE, ADDR, Mem_Bus, AN, seven);
  Memory MEM(CS, WE, CLK, ADDR, Mem_Bus);

endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

module Memory(CS, WE, CLK, ADDR, Mem_Bus);
  input CS;
  input WE;
  input CLK;
  input [6:0] ADDR;
  inout [31:0] Mem_Bus;

  reg [31:0] data_out;
  reg [31:0] RAM [0:127];
  integer i;

  initial
  begin
    /* Write your Verilog-Text IO code here */
    $readmemh("lab7b.txt", RAM);
    for(i = 41; i < 128; i = i+1) RAM[i] = 32'd0;
  end

  assign Mem_Bus = ((CS == 1'b0) || (WE == 1'b1)) ? 32'bZ : data_out;

  always @(negedge CLK)
  begin

    if((CS == 1'b1) && (WE == 1'b1))
      RAM[ADDR] <= Mem_Bus[31:0];

    data_out <= RAM[ADDR];
  end
endmodule

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Modified DR, SR1, and SR2 to make room for mhi and mLo

module REG(SW, BTN, CLK, RegW, DR, SR1, SR2, Reg_In, ReadReg1, ReadReg2, AN, seven);
  input CLK;
  input RegW;
  input [5:0] DR;
  input [5:0] SR1;
  input [5:0] SR2;
  input [31:0] Reg_In;
  input [1:0] BTN;
  input [2:0] SW;
  output [3:0] AN;
  output [7:1] seven;
  output reg [31:0] ReadReg1;
  output reg [31:0] ReadReg2;
  reg [15:0] value;
  wire sevenSegCLK;

  //parameter MHi = 6'd33, MLo = 6'd32;

  reg [31:0] REG [0:33];
    
  initial begin
    ReadReg1 = 0;
    ReadReg2 = 0;
  end
  
  always @(BTN or SW or REG[2] or REG[3])
  begin
    value = 0;
    case(SW)
        3'd1, 3'd2, 3'd3, 3'd4, 3'd5, 3'd6 : begin
            if(BTN == 2'b00) value = REG[2][15:0];
            else value = REG[2][31:16];
        end
        3'd0 : begin
            if(BTN == 2'b00) value = REG[2][15:0];
            else if(BTN == 2'b01) value = REG[2][31:16];
            else if(BTN == 2'b10) value = REG[3][15:0];
            else value = REG[3][31:16];
        end
        default : value = 0;
    endcase      
  end
  

  always @(posedge CLK)
  begin
    REG[1][2:0] <= SW; 
    if(RegW == 1'b1)
      REG[DR] <= Reg_In[31:0];

    ReadReg1 <= REG[SR1];
    ReadReg2 <= REG[SR2];
  end
  
  clockDivider C(28'd250000, CLK, sevenSegCLK);
  SevenSeg_Display S(sevenSegCLK, value, AN, seven);
endmodule


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

`define opcode instr[31:26]
`define f_code instr[5:0]
`define numshift instr[10:6]

module MIPS (SW, BTN, CLK, RST, CS, WE, ADDR, Mem_Bus, AN, seven);
  input CLK, RST;
  input [1:0] BTN;
  input [2:0] SW;
  output reg CS, WE;
  output [6:0] ADDR;
  inout [31:0] Mem_Bus;
  output [3:0] AN;
  output [7:1] seven;

  //special instructions (opcode == 000000), values of F code (bits 5-0):
  parameter add  = 6'b100000;
  parameter sub  = 6'b100010;
  parameter xor1 = 6'b100110;
  parameter and1 = 6'b100100;
  parameter or1  = 6'b100101;
  parameter slt  = 6'b101010;
  parameter srl  = 6'b000010;
  parameter sll  = 6'b000000;
  parameter jr   = 6'b001000;
     // new instructions
  parameter mult = 6'b011000;
  parameter mfhi = 6'b010000;
  parameter mflo = 6'b010010;
  parameter add8 = 6'b101101;
  parameter rbit = 6'b101111;
  parameter rev  = 6'b110000;
  parameter sadd = 6'b110001;
  parameter ssub = 6'b110010;

  //non-special instructions, values of opcodes:
  parameter addi = 6'b001000;
  parameter andi = 6'b001100;
  parameter ori  = 6'b001101;
  parameter lw   = 6'b100011;
  parameter sw   = 6'b101011;
  parameter beq  = 6'b000100;
  parameter bne  = 6'b000101;
  parameter j    = 6'b000010;
    // new instructions
  parameter jal  = 6'b000011;
  parameter lui  = 6'b001111;

  //instruction format
  parameter R = 2'd0;
  parameter I = 2'd1;
  parameter J = 2'd2;

  //internal signals
  reg [5:0] op, opsave;
  wire [1:0] format;
  reg [31:0] instr, alu_result;
  reg [6:0] pc, npc;
  wire [31:0] imm_ext, alu_in_A, alu_in_B, reg_in, readreg1, readreg2;
  reg [31:0] alu_result_save;
  reg alu_or_mem, alu_or_mem_save, regw, writing, reg_or_imm, reg_or_imm_save;
  reg fetchDorI;
  wire [5:0] dr, sr1, sr2;
  reg [2:0] state, nstate;
  // registers for the multiply
  reg [31:0] mhi, mlo, mlo_save, mhi_save;
  parameter MHi = 6'd33, MLo = 6'd32;
  integer i;
  //combinational
  assign imm_ext = (instr[15] == 1)? {16'hFFFF, instr[15:0]} : {16'h0000, instr[15:0]};//Sign extend immediate field
  // added J format for jal
  assign dr = (format == R)? ( 
                              (`f_code == mult)? (
                                                   (state == 3'd3)? MHi : MLo
                                                 ) : (`f_code == rbit || `f_code == rev) ?
                                                        {1'b0,(instr[25:21])} : {1'b0,(instr[15:11])} 
                              ) : (
                                   (format == J)? 6'd31 : {1'b0,instr[20:16]}
                                   ); //Destination Register MUX (MUX1)
  assign alu_in_A = readreg1;
  assign alu_in_B = (reg_or_imm_save)? imm_ext : readreg2; //ALU MUX (MUX2)
  assign reg_in = (alu_or_mem_save)? Mem_Bus : (  
                                                 (`f_code == mult)? 
                                                 (
                                                   (state == 3'd3)? mhi_save : mlo_save
                                                 ) : (alu_result_save)
                                                ); //Data MUX
  // added 6'd3 to deal with jal
  assign format = (`opcode == 6'd0)? R : (((`opcode == 6'd2) || (`opcode == 6'd3))? J : I);
  assign Mem_Bus = (writing)? readreg2 : 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;
  assign sr1 = (`f_code == mfhi)? MHi : ((`f_code == mflo)? MLo : {1'b0, instr[25:21]});
  assign sr2 = {1'b0, instr[20:16]};

  //drive memory bus only during writes
  assign ADDR = (fetchDorI)? pc : alu_result_save[6:0]; //ADDR Mux
  REG Register(SW, BTN, CLK, regw, dr, sr1, sr2, reg_in, readreg1, readreg2, AN, seven);

  initial begin
    op = and1; opsave = and1;
    state = 3'b0; nstate = 3'b0;
    alu_or_mem = 0;
    regw = 0;
    fetchDorI = 0;
    writing = 0;
    reg_or_imm = 0; reg_or_imm_save = 0;
    alu_or_mem_save = 0;
  end

  always @(*)
  begin
    fetchDorI = 0; CS = 0; WE = 0; regw = 0; writing = 0; alu_result = 32'd0;
    npc = pc; op = jr; reg_or_imm = 0; alu_or_mem = 0; nstate = 3'd0; mlo = 32'd0;
    mhi = 32'd0;
    case (state)
      0: begin //fetch
        npc = pc + 7'd1; CS = 1; nstate = 3'd1;
        fetchDorI = 1;
      end
      1: begin //decode
        nstate = 3'd2; reg_or_imm = 0; alu_or_mem = 0;
        if (format == J) begin //jump, and finish
          if (`opcode == j) begin
            // npc = {pc[31:26], instr[25:0]};
            npc = instr[6:0];
            nstate = 3'd0;
          end
        end
        else if (format == R) begin//register instructions
          op = `f_code;
        end
        else if (format == I) begin //immediate instructions
          reg_or_imm = 1;
          if(`opcode == lw) begin
            op = add;
            alu_or_mem = 1;
          end
          else if ((`opcode == lw)||(`opcode == sw)||(`opcode == addi)) op = add;
          else if ((`opcode == beq)||(`opcode == bne)) begin
            op = sub;
            reg_or_imm = 0;
          end
          else if (`opcode == andi) op = and1;
          else if (`opcode == ori) op = or1;
        end
      end
      2: begin //execute
        nstate = 3'd3;
        if (opsave == and1) alu_result = alu_in_A & alu_in_B;
        else if (opsave == or1) alu_result = alu_in_A | alu_in_B;
        else if (opsave == add) alu_result = alu_in_A + alu_in_B;
        else if (opsave == sub) alu_result = alu_in_A - alu_in_B;
        else if (opsave == srl) alu_result = alu_in_B >> `numshift;
        else if (opsave == sll) alu_result = alu_in_B << `numshift;
        else if (opsave == slt) alu_result = (alu_in_A < alu_in_B)? 32'd1 : 32'd0;
        else if (opsave == xor1) alu_result = alu_in_A ^ alu_in_B;
        else if (opsave == mfhi) alu_result = alu_in_A;
        else if (opsave == mflo) alu_result = alu_in_A;
        else if (opsave == lui) begin
            alu_result = alu_in_B << 16;
        end
        else if (opsave == add8) begin
            alu_result[31:24] = alu_in_A[31:24] + alu_in_B[31:24];
            alu_result[23:16] = alu_in_A[23:16] + alu_in_B[23:16];
            alu_result[15:8] = alu_in_A[15:8] + alu_in_B[15:8];
            alu_result[7:0] = alu_in_A[7:0] + alu_in_B[7:0];
        end
        else if (opsave == rbit) begin
            for(i = 0; i < 32; i = i+1) alu_result[i] = alu_in_B[31-i];
        end
        else if (opsave == rev) begin
            alu_result[31:24] = alu_in_B[7:0];
            alu_result[23:16] = alu_in_B[15:8];
            alu_result[15:8] = alu_in_B[23:16];
            alu_result[7:0] = alu_in_B[31:24];
        end
        else if (opsave == sadd) begin
            if(alu_in_A + alu_in_B > 4294967295) alu_result = 4294967295;
            else alu_result = alu_in_A + alu_in_B;
        end
        else if (opsave == ssub) begin
            if(alu_in_A - alu_in_B < 0) alu_result = 0;
            else alu_result = alu_in_A - alu_in_B;
        end
        // added for jal
        else if (opsave == jal) begin 
          alu_result = pc;
          npc = instr[6:0];
        end
        // added for mult
        else if (opsave == mult) {mhi, mlo} = alu_in_A * alu_in_B; 
        if (((alu_in_A == alu_in_B)&&(`opcode == beq)) || ((alu_in_A != alu_in_B)&&(`opcode == bne))) begin
          npc = pc + imm_ext[6:0];
          nstate = 3'd0;
        end
        else if ((`opcode == bne)||(`opcode == beq)) nstate = 3'd0;
        else if (opsave == jr) begin
          npc = alu_in_A[6:0];
          nstate = 3'd0;
        end
      end
      3: begin //prepare to write to mem
        nstate = 3'd0;
        if ((format == R)||(`opcode == addi)||(`opcode == andi)||(`opcode == ori)||(`opcode == jal)) regw = 1;
        // added for mult
        else if (`opcode == mult) begin
          regw = 1;
          nstate = 3'd4;
        end
        else if (`opcode == sw) begin
          CS = 1;
          WE = 1;
          writing = 1;
        end
        else if (`opcode == lw) begin
          CS = 1;
          nstate = 3'd4;
        end
      end
      4: begin
        nstate = 3'd0;
        CS = 1;
        if (`opcode == lw) regw = 1;
        // added for mult
        else if (`opcode == mult) begin
          CS = 0;
          regw = 1;
        end
      end
    endcase
  end //always

  always @(posedge CLK) begin

    if (RST) begin
      state <= 3'd0;
      pc <= 7'd0;
    end
    else begin
      state <= nstate;
      pc <= npc;
    end

    if (state == 3'd0) instr <= Mem_Bus;
    else if (state == 3'd1) begin
      opsave <= op;
      reg_or_imm_save <= reg_or_imm;
      alu_or_mem_save <= alu_or_mem;
    end
    else if (state == 3'd2) begin
      mlo_save <= mlo;
      mhi_save <= mhi;
      alu_result_save <= alu_result;
    end

  end //always

endmodule

module SevenSeg_Display(CLK, num, AN, seven);

input [15:0] num;
input CLK;
output [3:0] AN;
output [7:1] seven;

reg [1:0] sevenSeg_state, sevenSeg_nextState;
reg [3:0] binary;
reg [3:0] AN;

always @(sevenSeg_state or num)
begin
    AN = 4'b1111;
	sevenSeg_nextState = 0;
	case(sevenSeg_state)
		0 : begin
			AN[0] = 0;
			sevenSeg_nextState = 1;
			binary = num[3:0];
		end
		1 : begin
		    AN[1] = 0;
			sevenSeg_nextState = 2;
			binary = num[7:4];
		end
		2 : begin
		    AN[2] = 0;
            sevenSeg_nextState = 3;
            binary = num[11:8];
		end
		3 : begin
		    AN[3] = 0;
            sevenSeg_nextState = 0;
            binary = num[15:12];
		end
		default : begin
		    sevenSeg_nextState = 0;
		    binary = num[3:0];
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