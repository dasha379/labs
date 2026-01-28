vlib work

vlog -sv ../rtl/debouncer.sv
vlog -sv ../rtl/debouncer_wr.sv
vlog -sv debouncer_tb.sv

vsim -novopt debouncer_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full" 
