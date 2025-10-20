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
// CREATED		"Mon Oct 20 07:17:17 2025"

module mux4_1(
	data0_i,
	data1_i,
	data2_i,
	data3_i,
	direction_i,
	data_o
);


input wire	[1:0] data0_i;
input wire	[1:0] data1_i;
input wire	[1:0] data2_i;
input wire	[1:0] data3_i;
input wire	[1:0] direction_i;
output wire	[1:0] data_o;

wire	[1:0] data_o_ALTERA_SYNTHESIZED;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;




assign	SYNTHESIZED_WIRE_16 =  ~direction_i[1];

assign	SYNTHESIZED_WIRE_17 =  ~direction_i[0];

assign	SYNTHESIZED_WIRE_2 = direction_i[1] & direction_i[0] & data3_i[0];

assign	data_o_ALTERA_SYNTHESIZED[0] = SYNTHESIZED_WIRE_0 | SYNTHESIZED_WIRE_1 | SYNTHESIZED_WIRE_2 | SYNTHESIZED_WIRE_3;

assign	SYNTHESIZED_WIRE_8 = SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17 & data0_i[1];

assign	SYNTHESIZED_WIRE_11 = SYNTHESIZED_WIRE_16 & direction_i[0] & data1_i[1];

assign	SYNTHESIZED_WIRE_9 = direction_i[1] & SYNTHESIZED_WIRE_17 & data2_i[1];

assign	data_o_ALTERA_SYNTHESIZED[1] = SYNTHESIZED_WIRE_8 | SYNTHESIZED_WIRE_9 | SYNTHESIZED_WIRE_10 | SYNTHESIZED_WIRE_11;

assign	SYNTHESIZED_WIRE_10 = direction_i[1] & direction_i[0] & data3_i[1];

assign	SYNTHESIZED_WIRE_0 = SYNTHESIZED_WIRE_16 & SYNTHESIZED_WIRE_17 & data0_i[0];

assign	SYNTHESIZED_WIRE_3 = SYNTHESIZED_WIRE_16 & direction_i[0] & data1_i[0];

assign	SYNTHESIZED_WIRE_1 = direction_i[1] & SYNTHESIZED_WIRE_17 & data2_i[0];

assign	data_o = data_o_ALTERA_SYNTHESIZED;

endmodule
