module priority_encoder_wrapper # (
  parameter WIDTH = 8
)(
  input                        clk_i,
  input                        srst_i,
  input        [WIDTH - 1 : 0] data_i,
  input                        data_val_i,
  output logic [WIDTH - 1 : 0] data_left_o,
  output logic [WIDTH - 1 : 0] data_right_o,
  output logic                 data_val_o
);

  logic rst, valid;
  logic [WIDTH - 1 : 0] data;

  logic [WIDTH - 1 : 0] data_l, data_r;
  logic valid_o;

  always_ff @ (posedge clk_i)
    begin
      rst   <= srst_i;
      valid <= data_val_i;
      data  <= data_i;

      data_left_o  <= data_l;
      data_right_o <= data_r;
      data_val_o   <= valid_o;
    end
  
  priority_encoder #(
    .WIDTH(WIDTH)
  ) wrap (
    .clk_i       ( clk_i  ),
    .srst_i      ( rst    ),
    .data_i      ( data   ),
    .data_val_i  ( valid  ),
    .data_left_o ( data_l ),
    .data_right_o( data_r ),
    .data_val_o  ( valid_o)
  );

endmodule
