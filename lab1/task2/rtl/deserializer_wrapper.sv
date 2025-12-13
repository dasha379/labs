module deserializer_wrapper(
  input               clk_i,
  input               srst_i,
  input               data_i,
  input               data_val_i,
  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

  logic        srst, serial_data, serial_val;
  logic [15:0] parallel_data;
  logic        parallel_val;

  always_ff @ (posedge clk_i)
    begin
      srst             <= srst_i;
      serial_data      <= data_i;
      serial_val       <= data_val_i;

      deser_data_o     <= parallel_data;
      deser_data_val_o <= parallel_val;
    end

  deserializer wrap(
    .clk_i(clk_i),
    .srst_i(srst),
    .data_i(serial_data),
    .data_val_i(serial_val),
    .deser_data_o(parallel_data),
    .deser_data_val_o(parallel_val)
  );

endmodule