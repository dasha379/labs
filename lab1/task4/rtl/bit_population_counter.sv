module bit_population_counter #(
  parameter WIDTH = 8
)(
  input  logic                     clk_i,
  input  logic                     srst_i,
  input  logic [WIDTH - 1 : 0]     data_i,
  input  logic                     data_val_i,

  output logic [$clog2(WIDTH) : 0] data_o,
  output logic                     data_val_o
);

  logic [$clog2(WIDTH) : 0] cnt;

  always_ff @ (posedge clk_i)
    begin
      if (srst_i) data_val_o <= '0;
      else data_val_o <= data_val_i;
    end

  always_ff @ (posedge clk_i)
    begin
      if (srst_i) data_o <= '0;
      else if (data_val_i)
        data_o <= cnt;
    end

  always_comb
    begin
      cnt = '0;
      for (int i = 0; i < WIDTH; ++i)
        cnt = cnt + data_i[i];
    end

endmodule