set SRC "../../src"

proc compilecode {} {
    global SRC

    vlog -novopt ${SRC}/common.sv
    vlog -novopt ${SRC}/divider.sv
    vlog -novopt ${SRC}/i2s_deser.sv
    vlog -novopt ${SRC}/signal_indicator.sv
    vlog -novopt ${SRC}/snos.sv
    vlog -novopt ${SRC}/rj_transceiver.sv
    vlog -novopt ${SRC}/nos_dac_transceiver/nos_dac_full.sv
    vlog -novopt ${SRC}/nos_dac_transceiver/nos_dac_half.sv
    vlog -novopt ${SRC}/nos_dac_transceiver/nos_dac_transceiver.sv
    
    vlog -novopt pack.sv
    vlog -novopt i2s_transmitter.sv
    vlog -novopt tb.sv
}

proc setupsim {} {
    vsim -novopt -onfinish final tb

    log -r /*

    run -all

    add wave /UUT/mclk_in /UUT/pll_clk /UUT/mclk_out
    add wave /UUT/i2s_mcu_lrck /UUT/i2s_mcu_data /UUT/i2s_mcu_bck
    add wave /UUT/i2s_dac_lrck /UUT/i2s_dac_data /UUT/i2s_dac_bck /UUT/i2s_dac_data_r
    wave zoom full
}

alias "c" compilecode
alias "s" setupsim

