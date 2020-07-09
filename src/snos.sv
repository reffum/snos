//
// SNOS(Simple NOS) project. Top level module
//
import common::*;

module snos
  (
   // Configuration inputs
   input [15:1]       j,

   // Indication signals
   output logic       p_d,
   output logic       bit_6, bit_8, bit_10,
   output logic       d_5, d_7, d_9, p_x8,

   // Leds
   output logic [2:1] led,

   // DAC control signals
   output logic       dac_44_48, /* 0 - 44, 1 - 48 */
   output logic       dac_mute,
   output logic [1:0] dac_f, /* DAC sample rate */
   output logic       dac_dsd, /* 0 - DSD, 1 - PCM */
   output logic       dac_reset,

   // DAC serial data channel
   output logic       i2s_dac_lrck,
   output logic       i2s_dac_data,
   output logic       i2s_dac_bck,
   output logic       i2s_dac_data_r,

   // MCLK input
   input 	      mclk_in,

   // MCLK output logic to MCU
   output logic       mclk_out,
   
   // MCU serail data input
   input 	      i2s_mcu_lrck,
   input 	      i2s_mcu_data,
   input 	      i2s_mcu_bck,

   // DAC reset from MCU
   input 	      mcu_dac_reset, 

   // Input clock
   input 	      clk,
  
   // Control signals from MCU
   input 	      mcu_44_48, /* 44 - 0, 48 - 1*/ mcu_mute,
   input [1:0] 	      mcu_f,
   input 	      mcu_dsd_on, /* 0 - DSD, 1 - PCM */
   input 	      mcu_bit_6, mcu_bit_8, mcu_bit_10,
   input 	      mcu_d5, mcu_d7, mcu_d9,
   input 	      mcu_p_d,

   // External PLL signals
   input 	      pll_clkout,
   inout [1:0] 	      pll_s,
   output 	      pll_clk,

   output logic       reset_mcu
   );

   //
   // Nets
   //

   logic 	resetn = 1'b1;

   // Input I2S nets
   I2S i2s;
   
   // NOS DAC nets
   logic 	nos_bck, nos_data_r, nos_data_l, nos_le;

   // RJ16, RJ24, LJ nets
   logic 	rj24_bck, rj24_lrck, rj24_d;
   logic 	rj16_bck, rj16_lrck, rj16_d;
   logic 	lj_bck, lj_lrck, lj_d;
   
   // nos_dac_transceiver control signals
   logic 	nos_bck_cont;
   NOS_BITNUM nos_bitnum;
   logic 	nos_full;
   
   // Parallel data
   // High word - left channel,
   // Low word - right channel
   logic [63:0] i2s_data;
   logic 	i2s_valid;

   // Input I2S data bitnum
   BITNUM bitnum;

   // Input I2S bitrate
   BITRATE bitrate;

   // Input reference
   Reference reference;
   
   // Master clock frequency
   MCLK mclk_sel;

   // Master clock
   logic 	mclk;

   // pll_s inout logic
   logic [1:0] 	pll_s_i, pll_s_o, pll_s_t;
   
   //
   // Nets logic
   //

   // pll_s logic
   assign pll_s_i = pll_s;

   genvar 	i;
   for(i = 0; i < $size(pll_s); i++)
     assign pll_s[i] = (pll_s_t[i] == 1'b1) ?  pll_s_o : 1'bz;
   
   
   // Input I2S interface
   assign i2s.bck = i2s_mcu_bck;
   assign i2s.data = i2s_mcu_data;
   assign i2s.lrck = i2s_mcu_lrck;
   
   // Bitnum assigment from mcu_bit_* signals
   always_comb begin
      logic [2:0] b;
      b = {mcu_bit_6, mcu_bit_8, mcu_bit_10};

      if(b === 3'b100)
	bitnum = b16;
      else if(b === 3'b110)
	bitnum = b24;
      else
	bitnum = b32;
   end

   // Bitrate assiment from mcu_f
   always_comb begin
      
      if(mcu_f == 2'b00)
	bitrate = x1;
      else if(mcu_f == 2'b01)
	bitrate = x2;
      else if(mcu_f == 2'b10)
	bitrate = x4;
      else
	bitrate = x8;
   end // always_comb

   // NOS BCK CONT/STOP
   always_comb begin
      if(j[14] === 1'b1)
	nos_bck_cont = 1'b1;
      else
	nos_bck_cont = 1'b0;
   end

   // NOS FULL/HALF
   always_comb begin
      if(j[13])
	nos_full = 1'b1;
      else
	nos_full = 1'b0;
   end
   
   
   // NOS bitnum select
   always_comb begin
      logic [1:0] s;
      s  = j[12:11];

      if(s === 2'b11)
	nos_bitnum = NOS16;
      else if(s === 2'b01)
	nos_bitnum = NOS18;
      else if(s === 2'b10)
	nos_bitnum = NOS20;
      else
	nos_bitnum = NOS24;
   end // always_comb

   // Master clock frequency select
   always_comb begin
      logic [2:0] s;
      s = j[9:7];

      if(s === 3'b000)
	mclk_sel = MCLK_256fs;
      else if(s === 3'b001)
	mclk_sel = MCLK_384fs;
      else if(s === 3'b111)
	mclk_sel = MCLK_512fs;
      else if(s === 3'b110)
	mclk_sel = MCLK_768fs;
      else
	mclk_sel = MCLK_1024fs;
   end // always_comb

   
   
   //
   // Modules
   //

   // RJ16
   rj_transceiver #(.BITS(16)) rj_transceiver_16
     (
      .clk(i2s.bck),
      .data(i2s_data),
      .start(i2s_valid),

      .bck(rj16_bck),
      .lrck(rj16_lrck),
      .d(rj16_d)
      );
   
   // RJ24
   rj_transceiver #(.BITS(24)) rj_transceiver_24
     (
      .clk(i2s.bck),
      .data(i2s_data),
      .start(i2s_valid),

      .bck(rj24_bck),
      .lrck(rj24_lrck),
      .d(rj24_d)
      );

   // LJ
   rj_transceiver #(.BITS(32)) lj_transceiver
     (
      .clk(i2s.bck),
      .data(i2s_data),
      .start(i2s_valid),

      .bck(lj_bck),
      .lrck(lj_lrck),
      .d(lj_d)
      );
   
   // NOS DAC module. Convert data from parallel form to
   // NOS DAC output
   nos_dac_transceiver nos_dac_transceiver_inst
     (
      .clk(mclk),
      .resetn(resetn),
      .data(i2s_data),
      .start(i2s_valid),

      .bck_cont(nos_bck_cont),
      .nos_bitnum(nos_bitnum),
      .data_bits(bitnum),
      .full(nos_full),

      .bck(nos_bck),
      .data_r(nos_data_r),
      .data_l(nos_data_l),
      .le(nos_le)
      );

   // I2S deserializer
   // Convert I2S serial stream to parralel
   i2s_deser i2s_deser_inst
     (
      .i2s(i2s),
      .out(i2s_data),
      .valid(i2s_valid)
      );
   
   //
   // Data outptut
   //
   always_comb begin
      // Default: I2S
      i2s_dac_lrck <= i2s_mcu_lrck;
      i2s_dac_bck <= i2s_mcu_bck;
      i2s_dac_data <= i2s_mcu_data;
      i2s_dac_data_r <= 1'b0;
      
      // DSD mode
      if( !mcu_dsd_on) begin
	 i2s_dac_lrck <= i2s_mcu_lrck;
	 i2s_dac_bck <= i2s_mcu_bck;
	 i2s_dac_data <= i2s_mcu_data;
	 i2s_dac_data_r <= 1'b0;
      end else if( !j[10] ) begin // NOS DAC 
	 i2s_dac_lrck <= nos_le;
	 i2s_dac_bck <= nos_bck;
	 i2s_dac_data <= nos_data_l;
	 i2s_dac_data_r <= nos_data_r;
      end else begin
	 i2s_dac_data_r <= 1'b0;
	 
	 case(j[12:11])
	   // LJ
	   2'b00: begin
	      i2s_dac_lrck <= lj_lrck;
	      i2s_dac_bck <= lj_bck;
	      i2s_dac_data <= lj_d;
	   end

	   // RJ24
	   2'b01:begin
	      i2s_dac_lrck <= rj24_lrck;
	      i2s_dac_bck <= rj24_bck;
	      i2s_dac_data <= rj24_d;
	   end

	   // RJ16
	   2'b10: begin
	      i2s_dac_lrck <= rj16_lrck;
	      i2s_dac_bck <= rj16_bck;
	      i2s_dac_data <= rj16_d;
	   end

	   // I2S normal
	   2'b11: begin
	      i2s_dac_lrck <= i2s_mcu_lrck;
	      i2s_dac_bck <= i2s_mcu_bck;
	      i2s_dac_data <= i2s_mcu_data;
	   end
	 endcase // case (j[12:11])
      end
   end // always_comb

   //
   // PLL controls.
   //
   logic pll_clk_div3, pll_clk_div2, mclk_in_div2;
   
   assign pll_clk = mclk_in;
   
   always_comb begin
      pll_s_o <= 2'b00;
      pll_s_t <= 2'b11;
      
      mclk <= 1'b0;
      
      if(mclk_sel == MCLK_256fs) begin
	 pll_s_o <= 2'b00;
	 pll_s_t <= 2'b11;
	 mclk <= pll_clkout;
      end else if(mclk_sel == MCLK_384fs) begin
	 pll_s_o <= 2'b10; // 4X
	 pll_s_t <= 2'b11;
	 mclk <= pll_clk_div3;
      end else if (mclk_sel == MCLK_512fs) begin
	 mclk <= mclk_in;
      end else if(mclk_sel == MCLK_768fs) begin
	 pll_s_o <= 2'b00;// 3X
	 pll_s_t <= 2'b01;
	 mclk <= pll_clk_div2;
      end else if(mclk_sel == MCLK_1024fs) begin
	 mclk <= mclk_in_div2;
      end
   end // always_comb

   divider 
     #( 
	.COEF(3)
	) 
   pll_clk_3_divider
     (
      .in(pll_clkout),
      .out(pll_clk_div3)
      );

   divider
     #(
       .COEF(2)
       )
   pll_clk_2_divider
     (
      .in(pll_clkout),
      .out(pll_clk_div2)
      );
   
   divider
     #(
       .COEF(2)
       )
   mclk_in_2_divider
     (
      .in(mclk_in),
      .out(mclk_in_div2)
      );
   
   //
   // LEDs indication
   //
   signal_indicator data_indicator
     (
      .clk(clk),
      .resetn(resetn),
      .in(i2s_mcu_bck),
      .out(led[2])
      );

   signal_indicator mclk_indicator
     (
      .clk(clk),
      .resetn(resetn),
      .in(mclk_in),
      .out(led[1])
      );

   //
   // Indication
   //
   always_comb begin
      // Normal indication
      if(j[15]) begin
	 p_d <= mcu_p_d;
	 bit_6 <= mcu_bit_6;
	 bit_8 <= mcu_bit_8;
	 bit_10 <= mcu_bit_10;
	 d_5 <= mcu_d5;
	 d_7 <= mcu_d7;
	 d_9 <= mcu_d9;
	 p_x8 <= 1'b0;

	 // Alternative indication
      end else begin
	 bit_6 <= mcu_44_48;
	 bit_8 <= ~mcu_44_48;
	 bit_10 <= !(bitrate == x2);
	 d_5 <= mcu_dsd_on;
	 d_7 <= !(bitrate == x1);
	 d_9 <= !(bitrate == x4);
	 p_d <= ~mcu_dsd_on;
	 p_x8 <= !(bitrate == x8);
      end // else: !if(j[15])
   end // always_comb

   //
   // DAC control
   //
   always_comb begin
      dac_f <= 2'b00;
      
      if(j[1])
			dac_44_48 <= mcu_44_48;
      else
			dac_44_48 <= ~mcu_44_48;

      if(j[2])
			dac_mute <= mcu_mute;
      else
			dac_mute <= ~mcu_mute;

      if(j[4:3] == 2'b00) begin
	 case (bitrate)
	   x1: dac_f <= 2'b00;
	   x2: dac_f <= 2'b01;
	   x4: dac_f <= 2'b10;
	   x8: dac_f <= 2'b10;
	 endcase // case bitrate
      end else if (j[4:3] == 2'b10) begin
	 case (bitrate)
	   x1: dac_f <= 2'b11;
	   x2: dac_f <= 2'b00;
	   x4: dac_f <= 2'b00;
	   x8: dac_f <= 2'b00;
	 endcase // case bitrate
      end else if( j[4:3] == 2'b01) begin
	 case (bitrate)
	   x1: dac_f <= 2'b01;
	   x2: dac_f <= 2'b11;
	   x4: dac_f <= 2'b00;
	   x8: dac_f <= 2'b00;
	 endcase // case bitrate
      end else if(j[4:3] == 2'b11) begin
	 case (bitrate)
	   x1: dac_f <= 2'b00;
	   x2: dac_f <= 2'b01;
	   x4: dac_f <= 2'b10;
	   x8: dac_f <= 2'b11;
	 endcase // case bitrate
      end
      
      if(j[5])
			dac_dsd <= mcu_dsd_on;
      else
			dac_dsd <= ~mcu_dsd_on;

      if(j[6])
			dac_reset <= mcu_dac_reset;
      else
			dac_reset <= ~mcu_dac_reset;
   end // always_comb

   assign reset_mcu = 1'b1;
   assign mclk_out = mclk;
   
endmodule // snos

