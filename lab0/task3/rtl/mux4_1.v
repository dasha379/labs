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
// CREATED		"Thu Nov  6 13:23:30 2025"

module mux4_1(
	data0,
	data1,
	data2,
	data3,
	direction_i,
	data_o
);


input wire	data0;
input wire	data1;
input wire	data2;
input wire	data3;
input wire	[1:0] direction_i;
output wire	data_o;

wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;




assign	SYNTHESIZED_WIRE_8 =  ~direction_i[1];

assign	SYNTHESIZED_WIRE_9 =  ~direction_i[0];

assign	SYNTHESIZED_WIRE_4 = SYNTHESIZED_WIRE_8 & SYNTHESIZED_WIRE_9 & data0;

assign	SYNTHESIZED_WIRE_7 = SYNTHESIZED_WIRE_8 & direction_i[0] & data1;

assign	SYNTHESIZED_WIRE_5 = direction_i[1] & SYNTHESIZED_WIRE_9 & data2;

assign	SYNTHESIZED_WIRE_6 = direction_i[1] & direction_i[0] & data3;

assign	data_o = SYNTHESIZED_WIRE_4 | SYNTHESIZED_WIRE_5 | SYNTHESIZED_WIRE_6 | SYNTHESIZED_WIRE_7;


endmodule
