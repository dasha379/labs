vlib work

vlog -sv ../rtl/bit_population_counter.sv
vlog -sv ../rtl/bit_population_counter_wr.sv
vlog -sv bit_population_counter_tb.sv

vsim -novopt bit_population_counter_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"
