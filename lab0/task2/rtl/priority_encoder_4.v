// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
// CREATED		"Sun Oct 26 11:40:46 2025"

module priority_encoder_4(
	data_val_i,
	data_i,
	data_val_o,
	data_left_o,
	data_right_o
);


input wire	data_val_i;
input wire	[3:0] data_i;
output wire	data_val_o;
output wire	[3:0] data_left_o;
output wire	[3:0] data_right_o;

wire	[3:0] data_left_o_ALTERA_SYNTHESIZED;
wire	[3:0] data_right_o_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;

assign	data_val_o = data_val_i;



assign	data_left_o_ALTERA_SYNTHESIZED[3] = data_val_i & data_i[3];

assign	SYNTHESIZED_WIRE_6 = SYNTHESIZED_WIRE_14 & SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_16 & data_i[0];

assign	data_right_o_ALTERA_SYNTHESIZED[2] = data_i[2] & SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17 & data_val_i;

assign	data_right_o_ALTERA_SYNTHESIZED[1] = data_i[1] & SYNTHESIZED_WIRE_17 & data_val_i;

assign	data_right_o_ALTERA_SYNTHESIZED[0] = data_i[0] & data_val_i;

assign	data_left_o_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_6 & data_val_i;

assign	data_right_o_ALTERA_SYNTHESIZED[3] = data_val_i & SYNTHESIZED_WIRE_7;

assign	SYNTHESIZED_WIRE_7 = data_i[3] & SYNTHESIZED_WIRE_15 & SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17;

assign	data_left_o_ALTERA_SYNTHESIZED[2] = SYNTHESIZED_WIRE_14 & data_i[2] & data_val_i;

assign	SYNTHESIZED_WIRE_14 =  ~data_i[3];

assign	data_left_o_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_14 & SYNTHESIZED_WIRE_15 & data_i[1] & data_val_i;

assign	SYNTHESIZED_WIRE_15 =  ~data_i[2];

assign	SYNTHESIZED_WIRE_16 =  ~data_i[1];

assign	SYNTHESIZED_WIRE_17 =  ~data_i[0];

assign	data_left_o = data_left_o_ALTERA_SYNTHESIZED;
assign	data_right_o = data_right_o_ALTERA_SYNTHESIZED;

endmodule
