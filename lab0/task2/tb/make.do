vlib work

vlog ../rtl/priority_encoder_4.v
vlog -sv priority_encoder_4_tb.sv

vsim -novopt priority_encoder_4_tb -do "add log -r /*; add wave -r *; run -all"
