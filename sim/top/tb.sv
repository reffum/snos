//
// SNOS top-level simulation testbench
//
timeunit 1ns;
timeprecision 100ps;

import common::*;

module tb;

   //
   // Parameters
   //
   localparam time CLK_PERIOD = 41.6ns; // 24 MHz
   localparam time MCLK_PERIOD = 40.6ns;
   
   

   
   //
   // Nets connected to UUT
   //
   
   // Configuration logics
   logic [15:1]    j;
   

   // Indication signals
   logic 	p_d;
   logic 	bit_6, bit_8, bit_10;
   logic 	d_5, d_7, d_9, p_x8;

   // Leds
   logic [2:1] 	led;

   // DAC control signals
   logic 	dac_44_48; /* 0 - 44; 1 - 48 */
   logic 	dac_mute;
   logic [1:0] 	dac_f; /* DAC sample rate */
   logic 	dac_dsd; /* 0 - DSD; 1 - PCM */
   logic 	dac_reset;

   // DAC serial data channel
   logic 	i2s_dac_lrck;
   logic 	i2s_dac_data;
   logic 	i2s_dac_bck;
   logic 	i2s_dac_data_r;

   // MCLK logic
   logic 	mclk_in;

   // MCLK output logic to MCU
   logic 	mclk_out;

   // MCU serail data logic
   logic 	i2s_mcu_lrck;
   logic 	i2s_mcu_data;
   logic 	i2s_mcu_bck;

   // DAC reset from MCU
   logic 	mcu_dac_reset; 

   // Logic clock
   logic 	clk;
   
   // Control signals from MCU
   logic 	mcu_44_48, /* 44 - 0; 48 - 1*/ mcu_mute;
   logic [1:0] 	mcu_f;
   logic 	mcu_dsd_on; /* 0 - DSD; 1 - PCM */
   logic 	mcu_bit_6, mcu_bit_8, mcu_bit_10;
   logic 	mcu_d5, mcu_d7, mcu_d9;
   logic 	mcu_p_d;

   // External PLL signals
   logic 	pll_clkout;
   wire [1:0] 	pll_s;
   logic 	pll_clk;
   
   logic 	reset_mcu;
   

   // UUT instantance
   snos UUT
     (
      .*
      );

   i2s_transmitter i2s_transmitter_inst
     (
      .data(i2s_mcu_data),
      .lrck(i2s_mcu_lrck),
      .bck(i2s_mcu_bck)
      );

   //
   // Jumpers
   //
   assign j[1] = 1'b1;
   assign j[2] = 1'b1;
   assign j[4:3] = 2'b11;
   assign j[5] = 1'b1;
   assign j[6] = 1'b0;
   assign j[9:7] = 3'b111;
   assign j[10] = 1'b0;
   assign j[12:11] = 2'b00;
   assign j[13] = 1'b0;
   assign j[14] = 1'b0;
   assign j[15] = 1'b1;
   
   initial begin : CLK_GENERATION
      clk = 1'b0;
      forever #(CLK_PERIOD) clk = ~clk;
   end

   initial begin : MCLK_GENERATION
      mclk_in = 1'b0;
      forever #(MCLK_PERIOD) mclk_in = ~mclk_in;
   end

   initial begin : TEST
      localparam TEST_DATA_SIZE = 1024;
      localparam BITRATE = 44_100;
      localparam CHAN_NUM = 2;
      

      static logic [I2S_BITS-1:0] TestData[TEST_DATA_SIZE][CHAN_NUM];
      
      
      // Set I2S transmitter parameters
      i2s_transmitter_inst.SetBits(I2S_BITS);
      i2s_transmitter_inst.SetBitRate(BITRATE);

      assert(randomize(TestData) == 1);

      i2s_transmitter_inst.SetBits(I2S_BITS);
      i2s_transmitter_inst.SetBitRate(BITRATE);

      // Send data
      i2s_transmitter_inst.Send(TestData);      
      
      #10us;
      $finish;
      
   end
   
   
   
endmodule // tb
