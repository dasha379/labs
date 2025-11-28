vlib work

vlog -sv ../rtl/serializer.sv
vlog -sv ../rtl/serializer_wrapper.sv
vlog -sv serializer_tb.sv


vsim -novopt serializer_tb -do "add log -r /*; add wave -r *; run -all"
