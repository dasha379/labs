module debouncer #(
  parameter CLK_FREQ_MHZ = 150,
  parameter GLITCH_TIME_NS = 1000
)(
  input  logic clk_i,
  input  logic key_i,
  output logic key_pressed_stb_o
);

  localparam CNT = (CLK_FREQ_MHZ * GLITCH_TIME_NS) / 1000;

  logic [$clog2(CNT) - 1 : 0] count;
  logic key0, key1;
  logic state = 1'b1;

  always_ff @ (posedge clk_i)
    key0 <= key_i;
  
  always_ff @ (posedge clk_i)
    key1 <= key0;

  always_ff @ (posedge clk_i)
    begin
      if ( ( ~key1 ) && ( count + 1 < CNT ) )
        count <= count + 1'b1;
      else if ( key1 )
        count <= '0;
    end

  always_ff @ (posedge clk_i)
    begin
      if ( ( ~key1 ) && ( count + 1 == CNT ) )
        state <= 1'b1;
      else
        state <= '0;
    end

  logic delayed_state;

  always_ff @ (posedge clk_i)
    delayed_state <= state;

  assign key_pressed_stb_o = state && !delayed_state;

endmodule