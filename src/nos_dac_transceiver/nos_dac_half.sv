//
// NOS DAC half mode
//

import common::*;

module nos_dac_half
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
   
   output logic 	  bck, data_r, data_l, le
   );

   enum 		  {S0, S1, S2, S3, S4, S5, S6} state_cs, state_ns;

   // Registers
   logic [23:0] 	  reg_r_cs, reg_r_ns;
   logic [23:0] 	  reg_l_cs, reg_l_ns;
   byte 		  data_bits_num_cs, data_bits_num_ns;
   byte 		  bit_counter_cs, bit_counter_ns;

   always_ff @(posedge clk, negedge resetn) begin : STATE_REG
      if(!resetn)
	state_cs <= S0;
      else
	state_cs <= state_ns;
   end

   always_comb begin : STATE_LOGIC
      state_ns <= state_cs;

      case(state_cs)
	S0:
	  if(start)
	    state_ns <= S1;
	S1:
	  state_ns <= S2;

	S2:
	  if(bit_counter_cs == data_bits_num_cs)
	    state_ns <= S3;
	  else
	    state_ns <= S1;

	S3:
	  state_ns <= S4;
	S4:
	  if(bit_counter_cs == 1)
	    state_ns <= S5;
	  else
	    state_ns <= S3;

	S5:
	  state_ns <= S6;
	S6:
	  if(start)
	    state_ns <= S1;
	  else
	    state_ns <= S0;
      endcase // case (state_cs)
   end // block: STATE_LOGIC

   always_ff @(posedge clk, negedge resetn) begin : DATA_REGS
      if(!resetn) begin
	 reg_r_cs <= 24'h0;
	 reg_l_cs <= 24'h0;
	 data_bits_num_cs <= 8'd0;
	 bit_counter_cs <= 0;
      end else begin
	 reg_r_cs <= reg_r_ns;
	 reg_l_cs <= reg_l_ns;
	 data_bits_num_cs <= data_bits_num_ns;
	 bit_counter_cs <= bit_counter_ns;
      end // else: !if(!resetn)
   end // block: DATA_REGS

   always_comb begin : DATA_LOGIC
      reg_r_ns <= reg_r_cs;
      reg_l_ns <= reg_l_cs;
      data_bits_num_ns <= data_bits_num_cs;
      bit_counter_ns <= bit_counter_cs;

      case(state_cs)
	S0,S6: begin
	   bit_counter_ns <= 31;
	
	   if(nos_bitnum == NOS16)
	     data_bits_num_ns <= 8'd16;
	   else if(nos_bitnum == NOS18)
	     data_bits_num_ns <= 8'd18;
	   else if(nos_bitnum == NOS20)
	     data_bits_num_ns <= 8'd20;
	   else if(nos_bitnum == NOS24)
	     data_bits_num_ns <= 8'd24;

	   reg_r_ns <= 24'h0;
	   reg_l_ns <= 24'h0;

	   case(nos_bitnum)
	     NOS16: begin
		reg_r_ns[15:0] <= data[31:16];
		reg_l_ns[15:0] <= data[63:48];
	     end

	     NOS18: begin
		reg_r_ns[17:0] <= data[31:14];
		reg_l_ns[17:0] <= data[63:46];
	     end

	     NOS20: begin
		reg_r_ns[19:0] <= data[31:12];
		reg_l_ns[19:0] <= data[63:44];
	     end

	     NOS24: begin
		reg_r_ns[23:0] <= data[31:8];
		reg_l_ns[23:0] <= data[63:40];
	     end
	   endcase
	end 

	S2:
	  bit_counter_ns <= bit_counter_cs - 8'd1;

	S4: begin
	   bit_counter_ns <= bit_counter_cs - 8'd1;
	   reg_r_ns <= reg_r_cs << 1;
	   reg_l_ns <= reg_l_cs << 1;
	end

	default: ;
      endcase // case (state_cs)
   end // block: DATA_LOGIC

   always_comb begin : OUTPUTS
      bck <= 1'b0;
      data_r <= 1'b0;
      data_l <= 1'b0;
      le <= 1'b0;

      case(state_cs)
	S2:
	  if(bck_cont)
	    bck <= 1'b1;
	
	S3: begin
	   bck <= 1'b0;
	   data_r <= reg_r_cs[data_bits_num_cs-1];
	   data_l <= reg_l_cs[data_bits_num_cs-1];
	end

	S4: begin
	   bck <= 1'b1;
	   data_r <= reg_r_cs[data_bits_num_cs-1];
	   data_l <= reg_l_cs[data_bits_num_cs-1];
	end

	S5: begin
	   le <= 1'b1;
	   bck <= 1'b0;
	   data_r <= reg_r_cs[data_bits_num_cs-1];
	   data_l <= reg_l_cs[data_bits_num_cs-1];
	end

	S6: begin
	   le <= 1'b1;
	   bck <= 1'b1;
	   data_r <= reg_r_cs[data_bits_num_cs-1];
	   data_l <= reg_l_cs[data_bits_num_cs-1];
	end
	
	default: ;
      endcase // case (state_cs)
   end // block: OUTPUTS
   
endmodule // nos_dac_half
