//
// Testbench for signal_indicator
//
timeprecision 1ns;
timeunit 1ns;

module tb;
   // Connected to UUT ports
   logic clk, resetn, in, out;

   // UUT parameters
   localparam C_MAX = 1000;

   // Parameters
   localparam time CLK_PERIOD = 50ns;
   localparam time SIGNAL_PERIOD = 2us;
   
   signal_indicator #(.C_MAX(C_MAX)) UUT
     (
      .*
      );

   initial begin : CLK_GENERATION
      clk = 1'b0;
      forever #(CLK_PERIOD/2) clk = ~clk;
   end

   initial begin : TEST
      in = 1'b0;
      
      resetn = 1'b0;
      repeat(20) @(posedge clk);
      resetn = 1'b1;
      repeat(20) @(posedge clk);

      // Signal is present
      for(int i = 0; i < 20; i++)
	#(SIGNAL_PERIOD) in = ~in;

      // No signal
      #(100us);

      $finish;
      
   end // block: TEST
   
      
     
endmodule // tb
