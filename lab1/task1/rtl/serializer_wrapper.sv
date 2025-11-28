module serializer_wrapper(
  input        clk_i,
  input        srst_i,
  input [15:0] data_i,
  input [3:0]  data_mod_i,
  input        data_val_i,
  output logic ser_data_o,
  output logic ser_data_val_o,
  output logic busy_o
);

  logic        reg_rst;
  logic [15:0] reg_data_i;
  logic [3:0]  reg_data_mod_i;
  logic        reg_data_val_i;

  logic reg_data_o;
  logic reg_data_val_o;
  logic reg_busy;

  always @ (posedge clk_i)
    begin
      reg_rst        <= srst_i;
      reg_data_i     <= data_i;
      reg_data_mod_i <= data_mod_i;
      reg_data_val_i <= data_val_i;

      ser_data_o     <= reg_data_o;
      ser_data_val_o <= reg_data_val_o;
      busy_o         <= reg_busy;
    end

  serializer wrap(
    .clk_i(clk_i),
    .srst_i(reg_rst),
    .data_i(reg_data_i),
    .data_mod_i(reg_data_mod_i),
    .data_val_i(reg_data_val_i),
    .ser_data_o(reg_data_o),
    .ser_data_val_o(reg_data_val_o),
    .busy_o(reg_busy)
  );

endmodule