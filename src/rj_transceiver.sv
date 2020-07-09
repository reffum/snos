//
// RJ transceiver
//

import common::*;

//
// Send data in RJ format.
// Transmittion starts on start signal. It must be set to 1 on 1 clk.
//
module rj_transceiver
  (
   input 		  clk,
   // High word - left channel,
   // Low word - right channel
   input [I2S_BITS*2-1:0] data,
   input 		  start,

   // RJ signals
   output logic 	  lrck, bck, d
   );

   //
   // On start write data in shift register. Shift out data from
   // it on clk. First I2S_BITS - BITS bits must be 0.
   // 

   parameter BITS = 24;

   // Shift register. Data shifted on clk.
   // If start is 1, write data in it.
   logic [I2S_BITS*2-1:0] sr_ns, sr_cs;

   always_ff @(posedge clk) 
     sr_cs <= sr_ns;

   always_comb begin

      // Data for right and left channels
      automatic logic [BITS-1:0] l,r;

      l = data[I2S_BITS*2-1:2*I2S_BITS-BITS];
      r = data[I2S_BITS-1:I2S_BITS-BITS];
      
      if(start)
	sr_ns <= { {(I2S_BITS-BITS){1'b0}}, l, 
		   {(I2S_BITS-BITS){1'b0}}, r};
      else
	sr_ns <= {sr_cs[$size(sr_cs)-2:0], 1'b0};
   end

   // LRCK control. Counter count bits.
   // LRCK is 1 on high word(left channel), and is low on 0 on low word.
   byte bit_cnt_cs, bit_cnt_ns;

   always_ff @(posedge clk)
     bit_cnt_cs <= bit_cnt_ns;

   always_comb begin
      if(start || bit_cnt_cs == I2S_BITS*2-1)
	bit_cnt_ns <= 0;
      else
	bit_cnt_ns <= bit_cnt_cs + 8'd1;
   end

   // Outputs
   assign bck = ~clk;
   assign d = sr_cs[$size(sr_cs)-1];

   always_comb
     if(bit_cnt_cs < I2S_BITS)
       lrck <= 1'b1;
     else
       lrck <= 1'b0;
   
endmodule // rj_transceiver
