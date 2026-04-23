vlib work

vlog -sv ast_pkg.sv
vlog -sv ../rtl/ast_width_extender.sv
vlog -sv ast_interface.sv
vlog -sv ast_tb.sv

vsim -novopt ast_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"