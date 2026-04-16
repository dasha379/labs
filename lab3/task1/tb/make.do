vlib work

vlog -sv test_pkg.sv
vlog -sv ../rtl/lifo.sv
vlog -sv lifo_interface.sv

vlog -sv lifo_tb.sv

vsim -novopt lifo_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"
