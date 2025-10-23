vlib work

vlog ../rtl/mux4_1.v
vlog -sv mux_tb.sv

vsim -novopt mux_tb -do "add log -r /*; add wave *; run -all"


