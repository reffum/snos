//
// SNOS(Simple NOS) project. Top level module
//

module snos
  (
   // Configuration inputs
   input [15:1] j,

   // Indication signals
   output p_d,
   output 		    bit_6, bit_8, bit_10,
   output 		    d_5, d_7, d_9,

   // Leds
   output [2:1] led,

   // DAC control signals
   output dac_44_48, /* 0 - 44, 1 - 48 */
   output dac_mute,
   output [1:0] dac_f, /* DAC sample rate */
   output dac_dsd, /* 0 - DSD, 1 - PCM */
   output dac_reset,

   // DAC serial data channel
   output i2s_dac_lrck,
   output i2s_dac_data,
   output i2s_dac_bck,
   output i2s_dac_data_r,

   // MCLK input
   input mclk_in,

   // MCU serail data input
   input i2c_mcu_lrck,
   input i2c_mcu_data,
   input i2c_mcu_bck,

   // DAC reset from MCU
   input mcu_dac_reset, 

   // Input clock
   input clk,
   
   // Control signals from MCU
   input 		    mcu_44_48, mcu_mute,
   input [1:0] 		    mcu_f,
   input 		    mcu_dsd_on,
   input 		    mcu_bit_6, mcu_bit_8, mcu_bit_10,
   input mcu_d5, mcu_d7, mcu_d9,
   input mcu_p_d,

   // External PLL signals
   input pll_clkout,
   output [1:0] pll_s,
   output pll_clk
   );

   
endmodule // snos

