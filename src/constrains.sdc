create_clock -name clk -period 41.666ns [get_ports clk]
create_clock -name mclk_in -period 20ns  [get_ports  mclk_in]
create_clock -name pll_clkout -period 10ns [get_ports pll_clkout]
create_clock -name i2s_mcu_bck -period 50ns [get_ports i2s_mcu_bck]

set_false_path -from [get_clocks {i2s_mcu_bck}] -to [get_clocks {clk}]
set_false_path -from [get_clocks {mclk_in}] -to [get_clocks {clk}]
