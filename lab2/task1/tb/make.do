vlib work

vlog -sv ../rtl/fifo.sv
vlog -sv ../rtl/fifo_wrapper.sv

vlog /opt/fpga/quartus/18.1/quartus/eda/sim_lib/altera_mf.v

vlog -sv fifo_tb.sv

vsim -novopt fifo_tb -do "add log -r /*; add wave -r *; run -all; wave zoom full"
