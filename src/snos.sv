//
// SNOS(Simple NOS) project. Top level module
//

module snos
  (
   // Configuration inputs
   input [15:1] j,

   // Indication signals
   output 	p_d,
   output 	bit_6, bit_8, bit_10,
   output 	d_5, d_7, d_9,

   // Leds
   output [2:1] led,

   // DAC control signals
   output 	dac_44_48, /* 0 - 44, 1 - 48 */
   output 	dac_mute,
   output [1:0] dac_f, /* DAC sample rate */
   output 	dac_dsd, /* 0 - DSD, 1 - PCM */
   output 	dac_reset,

   // DAC serial data channel
   output 	i2s_dac_lrck,
   output 	i2s_dac_data,
   output 	i2s_dac_bck,
   output 	i2s_dac_data_r,

   // MCLK input
   input 	mclk_in,

   // MCU serail data input
   input 	i2c_mcu_lrck,
   input 	i2c_mcu_data,
   input 	i2c_mcu_bck,

   // DAC reset from MCU
   input 	mcu_dac_reset, 

   // Input clock
   input 	clk,
  
   // Control signals from MCU
   input 	mcu_44_48, mcu_mute,
   input [1:0] 	mcu_f,
   input 	mcu_dsd_on,
   input 	mcu_bit_6, mcu_bit_8, mcu_bit_10,
   input 	mcu_d5, mcu_d7, mcu_d9,
   input 	mcu_p_d,

   // External PLL signals
   input 	pll_clkout,
   output [1:0] pll_s,
   output 	pll_clk
   );

   //
   // Nets
   //

   logic 	clk;
   logic 	resetn;

   // Input I2S nets
   I2S i2s;
   
   // NOS DAC nets
   logic 	nos_bck, nos_data_r, nos_data_l, nos_le;

   // nos_dac_transceiver control signals
   logic 	nos_bck_cont, nos_start;
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

   

   //
   // Nets logic
   //

   // Input I2S interface
   assign i2s.bck = i2s_mcu_bck;
   assign i2s.data = i2s_mcu_data;
   assign i2s.lrck = i2s_mcu_lrck;

   // Bitnum assigment from mcu_bit_* signals
   always_comb begin
      logic [2:0] b = {mcu_bit_6, mcu_bit_8, mcu_bit_10};

      if(b === 3'b100)
	bitnum = b16;
      else if(b === 3'b110)
	bitnum = b24;
      else
	bitnum = b32;
   end

   // NOS bitnum select
   always_comb begin
      logic [1:0] s = j[12:11];

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
      logic [2:0] s = j[9:7];

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
   
   // NOS DAC module. Convert data from parallel form to
   // NOS DAC output
   nos_dac_transceiver nos_dac_transceiver_inst
     (
      .clk(clk),
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
   
   
   
endmodule // snos

