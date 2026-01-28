module debouncer_wr #(
  parameter CLK_FREQ_MHZ = 150,
  parameter GLITCH_TIME_NS = 1000
)(
  input  logic clk_i,
  input  logic key_i,

  output logic key_pressed_stb_o
);

  logic key, pressed_key;

  always_ff @ (posedge clk_i)
    begin
      key               <= key_i;
      key_pressed_stb_o <= pressed_key;
    end
  
  debouncer #(
    .CLK_FREQ_MHZ  ( CLK_FREQ_MHZ  ),
    .GLITCH_TIME_NS( GLITCH_TIME_NS)
  ) wrapper (
    .clk_i            ( clk_i       ),
    .key_i            ( key         ),
    .key_pressed_stb_o( pressed_key )
  );

endmodule