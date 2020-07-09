set SRC "../../src"

proc compilecode {} {
    global SRC

    vlog -novopt ${SRC}/common.sv
    vlog -novopt ${SRC}/divider.sv
    vlog -novopt ${SRC}/i2s_deser.sv
    vlog -novopt ${SRC}/signal_indicator.sv
    vlog -novopt ${SRC}/snos.sv
    
    vlog -novopt pack.sv
    vlog -novopt i2s_transmitter.sv
    vlog -novopt tb.sv
}

proc setupsim {} {
    vsim -novopt -onfinish final tb

    log -r /*

    run -all

    add wave /UUT/mclk_in add wave /UUT/pll_clk
}

alias "c" compilecode
alias "s" setupsim

