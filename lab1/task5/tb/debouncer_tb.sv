`timescale 1ns/1ps

module debouncer_tb;
  parameter CLK_FREQ_MHZ   = 150;
  parameter GLITCH_TIME_NS = 100;

  logic clk_i;
  logic key_i;
  logic key_pressed_stb_o;

  localparam CNT        = (CLK_FREQ_MHZ * GLITCH_TIME_NS) / 1000;
  localparam CLK_PERIOD = 1000 / CLK_FREQ_MHZ;

  debouncer #(
    .CLK_FREQ_MHZ     ( CLK_FREQ_MHZ   ),
    .GLITCH_TIME_NS   ( GLITCH_TIME_NS )
  ) DUT (
    .clk_i            ( clk_i             ),
    .key_i            ( key_i             ),
    .key_pressed_stb_o( key_pressed_stb_o )
  );

  initial
    begin
      clk_i = '0;
      forever #(CLK_PERIOD / 2) clk_i = ~clk_i;
    end

  int success;

  task automatic create_glitch(
    input int num_glithces,
    input int min_glitch,
    input int max_glitch
  );
    key_i <= 1'b1;
    @ (posedge clk_i);
    for (int i = 0; i < num_glithces; ++i)
      begin
        key_i <= ~key_i;
        repeat ($urandom_range(min_glitch, max_glitch)) 
          begin
            @ (posedge clk_i);
            if ( key_pressed_stb_o )
              begin
                $error("the button is not steadily pressed. expected: 0, got: 1");
                $stop();
              end
          end
      end
    key_i <= 1'b1;
  endtask

  task automatic random_press();
    int num_tests = $urandom_range(2, 7);
    for (int i = 0; i < num_tests; ++i)
      begin
        create_glitch($urandom_range(2, 10), CNT/5, CNT/2);
        success++;
      end
  endtask

  task automatic perfect_press();
    key_i <= '0;
    repeat (CNT) @ (posedge clk_i);
    key_i <= 1'b1;
    repeat (3) @ (posedge clk_i);

    if ( ~key_pressed_stb_o )
      begin
        $error("the button is steadily pressed. Expected: 1. Got: 0");
        $stop();
      end
    else
      success += 1;
  endtask

  task automatic long_press();
    int num = $urandom_range(2, 4);
    int c = 0;
    key_i <= '0;
    for (int i = 0; i < CNT * num; ++i)
      begin
        @(posedge clk_i);
        if ( key_pressed_stb_o ) c++; 
      end
    if (c > 1)
      begin
        $error("key_pressed_stb_o has to be up only once during long press");
        $stop();
      end
    else
      success++;
    key_i <= 1'b1;
  endtask

  initial
    begin
      key_i <= 1'b1;
      @(posedge clk_i);

      perfect_press();
      $display("perfect press test passed");
      @(posedge clk_i);

      random_press();
      $display("random presses test passed");
      @(posedge clk_i);

      long_press();
      $display("one long press test passed");
      $display("simulation is complete. passed %d tests", success);

      $finish();
    end

endmodule