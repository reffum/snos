proc compilecode {} {
    vlog -novopt ../../src/clk_div3.sv
    vlog -novopt ../../src/clk_div2.sv
    vlog -novopt tb.sv
}

proc setupsim {} {
    vsim -novopt -onfinish final tb
    log -r /*

    run -all

    add wave /resetn /in /out2 /out3
    wave zoom full
}

alias "c" compilecode
alias "s" setupsim

