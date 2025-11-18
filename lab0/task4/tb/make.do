vlib work

vlog ../rtl/crc_16_ansi.v
vlog -sv crc_16_ansi_tb.sv

vsim -novopt crc_16_ansi_tb -do "add log -r /*; add wave -r *; run -all"
