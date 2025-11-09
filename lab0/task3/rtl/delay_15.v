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
// CREATED		"Thu Nov  6 13:22:20 2025"

module delay_15(
	clk_i,
	rst_i,
	data_i,
	data_delay_i,
	data_o
);


input wire	clk_i;
input wire	rst_i;
input wire	data_i;
input wire	[3:0] data_delay_i;
output wire	data_o;

reg	[15:1] data;
wire	data_0;
wire	[1:0] direction_i;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;





always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[1] <= 0;
	end
else
	begin
	data[1] <= data_0;
	end
end

assign	data_0 = data_i;



always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[10] <= 0;
	end
else
	begin
	data[10] <= data[9];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[11] <= 0;
	end
else
	begin
	data[11] <= data[10];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[12] <= 0;
	end
else
	begin
	data[12] <= data[11];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[13] <= 0;
	end
else
	begin
	data[13] <= data[12];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[14] <= 0;
	end
else
	begin
	data[14] <= data[13];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[15] <= 0;
	end
else
	begin
	data[15] <= data[14];
	end
end


mux4_1	b2v_inst16(
	.data0(data_0),
	.data1(data[1]),
	.data2(data[2]),
	.data3(data[3]),
	.direction_i(direction_i),
	.data_o(SYNTHESIZED_WIRE_8));


mux4_1	b2v_inst17(
	.data0(data[4]),
	.data1(data[5]),
	.data2(data[6]),
	.data3(data[7]),
	.direction_i(direction_i),
	.data_o(SYNTHESIZED_WIRE_9));

assign	SYNTHESIZED_WIRE_19 =  ~rst_i;


mux4_1	b2v_inst19(
	.data0(data[8]),
	.data1(data[9]),
	.data2(data[10]),
	.data3(data[11]),
	.direction_i(direction_i),
	.data_o(SYNTHESIZED_WIRE_10));


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[2] <= 0;
	end
else
	begin
	data[2] <= data[1];
	end
end


mux4_1	b2v_inst20(
	.data0(data[12]),
	.data1(data[13]),
	.data2(data[14]),
	.data3(data[15]),
	.direction_i(direction_i),
	.data_o(SYNTHESIZED_WIRE_11));


mux4_1	b2v_inst21(
	.data0(SYNTHESIZED_WIRE_8),
	.data1(SYNTHESIZED_WIRE_9),
	.data2(SYNTHESIZED_WIRE_10),
	.data3(SYNTHESIZED_WIRE_11),
	.direction_i(data_delay_i[3:2]),
	.data_o(data_o));

assign	direction_i = data_delay_i[1:0];



always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[3] <= 0;
	end
else
	begin
	data[3] <= data[2];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[4] <= 0;
	end
else
	begin
	data[4] <= data[3];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[5] <= 0;
	end
else
	begin
	data[5] <= data[4];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[6] <= 0;
	end
else
	begin
	data[6] <= data[5];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[7] <= 0;
	end
else
	begin
	data[7] <= data[6];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[8] <= 0;
	end
else
	begin
	data[8] <= data[7];
	end
end


always@(posedge clk_i or negedge SYNTHESIZED_WIRE_19)
begin
if (!SYNTHESIZED_WIRE_19)
	begin
	data[9] <= 0;
	end
else
	begin
	data[9] <= data[8];
	end
end


endmodule
