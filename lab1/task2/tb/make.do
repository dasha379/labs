vlib work

vlog -sv ../rtl/deserializer.sv
vlog -sv ../rtl/deserializer_wrapper.sv
vlog -sv deserializer_tb.sv

vsim -novopt deserializer_tb -do "add log -r /*; add wave -r *; run -all"
