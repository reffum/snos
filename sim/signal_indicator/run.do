
set SRC "../../src"

proc compilecode {} {
    global SRC
    vlog -novopt ${SRC}/signal_indicator.sv
    vlog -novopt tb.sv
}

proc setupsim {} {
    vsim -novopt -onfinish final tb
    log -r /*

    run -all

    add wave /UUT/*

    wave zoom full
}

alias "c" compilecode
alias "s" setupsim

