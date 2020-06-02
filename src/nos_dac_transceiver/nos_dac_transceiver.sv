//
// NOS DAC transceiver.
//
import common::*;

module nos_dac_transceiver
  (
   input 		  clk,
   input 		  resetn,

   // High word - left channel,
   // Low word - right channel
   input [I2S_BITS*2-1:0] data,

   input 		  start,

   input 		  bck_cont,
   input 		  BITNUM data_bits,
   input 		  NOS_BITNUM nos_bitnum,
   
   // Full word lenght
   // 0 - 32
   // 1 - 64
   input 		  full,
   
   output logic 	  bck, data_r, data_l, le
   );

   logic 		  full_bck, full_data_r, full_data_l, full_le;
   logic 		  half_bck, half_data_r, half_data_l, half_le;
   
   
   nos_dac_full nos_dac_full_inst
     (
      .bck(full_bck),
      .data_r(full_data_r),
      .data_l(full_data_l),
      .le(full_le),
      .*
      );

   nos_dac_half nos_dac_half_inst
     (
      .bck(half_bck),
      .data_r(half_data_r),
      .data_l(half_data_l),
      .le(half_le),
      .*
      );
     

   always_comb begin
      if(full) begin
	 bck <= full_bck;
	 data_r <= full_data_r;
	 data_l <= full_data_l;
	 le <= full_le;
      end else begin
	 bck <= half_bck;
	 data_r <= half_data_r;
	 data_l <= half_data_l;
	 le <= half_le;
      end // else: !if(full)
   end // always_comb
   
endmodule // nos_dac_transceiver
