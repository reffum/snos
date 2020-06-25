timeprecision 1ns;
timeunit 1ns;


module tb;
   logic in, out2, out3;
   logic resetn = 1'b0;

   parameter SIG_PERIOD = 100ns;

   initial begin : SIG_GEN
      in = 1'b0;
      forever #(SIG_PERIOD/2) in = ~in;
   end

   initial begin
      resetn = 1'b0;
      #(1us) resetn = 1'b1;
      
      #100us $finish;
   end

   divider #(.COEF(2)) UUT0
     (
      .resetn,
      .in(in),
      .out(out2)
      );
   
   divider #(.COEF(3)) UUT1
     (
      .resetn,
      .in(in),
      .out(out3)
      );
   
endmodule // tb
