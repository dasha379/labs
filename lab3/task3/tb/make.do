vlib work

vlog -sv ast_pkg.sv
vlog -sv ../rtl/ast_dmx.sv
vlog -sv ast_interface_dir.sv
vlog -sv ast_interface.sv
vlog -sv ast_tb.sv

vsim ast_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"