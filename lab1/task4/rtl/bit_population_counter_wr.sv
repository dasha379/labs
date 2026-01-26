module bit_population_counter_wr #(
  parameter WIDTH = 8
)(
  input  logic                     clk_i,
  input  logic                     srst_i,
  input  logic [WIDTH - 1 : 0]     data_i,
  input  logic                     data_val_i,

  output logic [$clog2(WIDTH) : 0] data_o,
  output logic                     data_val_o
);

  logic rst, valid_i, valid_o;
  logic [WIDTH - 1 : 0] data_input;
  logic [$clog2(WIDTH) : 0] data_output;

  always_ff @ (posedge clk_i)
    begin
      rst        <= srst_i;
      data_input <= data_i;
      valid_i    <= data_val_i;

      data_o     <= data_output;
      data_val_o <= valid_o;
    end

  bit_population_counter #(
    .WIDTH(WIDTH)
  ) wrap (
    .clk_i     ( clk_i      ),
    .srst_i    ( rst        ),
    .data_i    ( data_input ),
    .data_val_i( valid_i    ),
    .data_o    ( data_output),
    .data_val_o( valid_o    )
  );

endmodule