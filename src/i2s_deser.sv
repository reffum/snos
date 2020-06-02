//
// I2S deserializer
//

import common::*;

module i2s_deser
  (
   // Input I2S 
   input 		   I2S i2s,

   // Output paralele data. Synchronious to I2S BCK.
   // Contain two I2S_BITS words.
   // High word - left channel
   // Low word - right channel
   output [I2S_BITS*2-1:0] out,
   output logic 	   valid
   );

   //
   // Shift 32 bits from I2S to shift register and output it
   // on out, set valid to 1 on 1 clock.
   //

   // Shift registers for left and right channels
   logic [I2S_BITS-1:0]    sr_l_ns, sr_l_cs;
   logic [I2S_BITS-1:0]    sr_r_ns, sr_r_cs;

   // In RIGHT state write data to right shift reg, in
   // LEFT in left.
   enum 		   {LEFT, RIGHT} state_cs, state_ns;

   // State logicout
   always_ff @(posedge i2s.bck)
     state_cs <= state_ns;

   always_comb begin
      state_ns <= state_cs;

      if(state_cs == LEFT && i2s.lrck == 1'b1)
	state_ns <= RIGHT;
      else if(state_cs == RIGHT && i2s.lrck == 1'b0)
	state_ns <= LEFT;
   end

   // Shift registers
   always_ff @(posedge i2s.bck) begin
      sr_l_cs <= sr_l_ns;
      sr_r_cs <= sr_r_ns;
   end

   always_comb begin
      sr_l_ns <= sr_l_cs;
      sr_r_ns <= sr_r_cs;

      if(state_cs == LEFT)
	sr_l_ns <= {sr_l_cs[$size(sr_l_cs)-2:0], i2s.data};
      else
	sr_r_ns <= {sr_r_cs[$size(sr_r_cs)-2:0], i2s.data};
   end

   // Output
   assign out = {sr_l_cs, sr_r_cs};

   // Valid set to 1 in first clock when state become LEFT
   logic valid_cs, valid_ns;

   always_ff @(posedge i2s.bck)
     valid_cs <= valid_ns;
   
   always_comb
     if(state_cs == RIGHT &&
	state_ns == LEFT)
       valid_ns <= 1'b1;
     else
       valid_ns <= 1'b0;

   assign valid = valid_cs;
   
endmodule // i2s_deser

   
   
