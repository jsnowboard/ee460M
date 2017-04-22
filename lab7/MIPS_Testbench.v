// You can use this skeleton testbench code, the textbook testbench code, or your own
module MIPS_Testbench ();
  reg CLK;
  reg RST;
  wire CS;
  wire WE;
  wire [31:0] Mem_Bus;
  wire [6:0] Address;

  initial
  begin
    CLK = 0;
  end

  MIPS CPU(CLK, RST, CS, WE, Address, Mem_Bus);
  Memory MEM(CS, WE, CLK, Address, Mem_Bus);

  always
  begin
    #5 CLK = !CLK;
  end

  always
  begin
    RST <= 1'b1; //reset the processor

    //Notice that the memory is initialize in the in the memory module not here

    @(posedge CLK);
    // driving reset low here puts processor in normal operating mode
    RST = 1'b0;

    /* add your testing code here */
    // you can add in a 'Halt' signal here as well to test Halt operation
    // you will be verifying your program operation using the
    // waveform viewer and/or self-checking operations

    $display("TEST COMPLETE");
    $stop;
  end

endmodule

// Testbench version 2
module mips_testbench2;
  reg CLK;
  wire CS, WE;

  parameter N = 10;
  reg[31:0] expected[N:1];
  
  wire[31:0] Address, Address_Mux, Mem_Bus_Wire;
  reg[31:0] AddressTB;
  wire WE_Mux, CS_Mux;
  reg init, rst, WE_TB, CS_TB;

  integer i;

  MIPS CPU(CLK, rst, CS, WE, Address, Mem_Bus_Wire);
  Memory MEM(CS_Mux, WE_Mux, CLK, Address_Mux, Mem_Bus_Wire);

  assign Address_Mux = (init)? AddressTB : Address;
  assign WE_Mux = (init)? WE_TB : WE;
  assign CS_Mux = (init)? CS_TB : CS;

  always
    #10 CLK = ~CLK;

  initial begin
    expected[1]  = 32'h00000006;
    expected[2]  = 32'h00000012;
    expected[3]  = 32'h00000018;
    expected[4]  = 32'h0000000C;
    expected[5]  = 32'h00000002;
    expected[6]  = 32'h00000016;
    expected[7]  = 32'h00000001;
    expected[8]  = 32'h00000120;
    expected[9]  = 32'h00000003;
    expected[10] = 32'h00412022;
    CLK = 0;
  end

  always begin
    rst = 1;
    @(posedge CLK);  // wait until posedge CLK
    // Initialize the instructions from the testbench
    init <= 1; CS_TB <= 1; WE_TB <= 1;
    @(posedge CLK);
    CS_TB <= 0; WE_TB <= 0; init <= 0;
    @(posedge CLK);
    rst <= 0;
    for(i = 1; i <= N; i = i + 1) begin
      @(posedge WE);  // When a store word is executed
      @(posedge CLK); 
      if (Mem_Bus_Wire != expected[i])
        $display("Output mismatch: got %d, expect %d", Mem_Bus_Wire, expected[i]);
    end
    $display("Testing Finished:");
    $stop;
  end
endmodule
