vlib work

vlog ../rtl/mux4_1.v
vlog ../rtl/delay_15.v
vlog -sv delay_15_tb.sv

vsim -novopt delay_15_tb -do "add log -r /*; add wave -r *; run -all"
