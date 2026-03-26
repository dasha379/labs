vlib work

vlog -sv ../rtl/true_dual_port_ram_single_clock.sv
vlog -sv ../rtl/bubble.sv
vlog -sv ../rtl/sorting.sv
vlog -sv ../rtl/sorting_wr.sv
vlog -sv sorting_tb.sv

vsim -novopt sorting_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"
