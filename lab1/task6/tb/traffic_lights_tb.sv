`timescale 1ns/1ps

module traffic_lights_tb;
  parameter BLINK_HALF_PERIOD_MS = 900;
  parameter BLINK_GREEN_TIME_TICK = 5;
  parameter RED_YELLOW_MS = 500;

  logic        clk_i;
  logic        srst_i;
  logic [2:0]  cmd_type_i;
  logic        cmd_valid_i;
  logic [15:0] cmd_data_i;

  logic        red_o;
  logic        yellow_o;
  logic        green_o;

  localparam CLK_FREQ_HZ = 2000;

  localparam int BLINK_HALF_PERIOD_TICKS = BLINK_HALF_PERIOD_MS * 2;
  localparam int RED_YELLOW_TICKS = RED_YELLOW_MS * 2;

  initial
    begin
      clk_i = '0;
      forever #250000 clk_i = ~clk_i;
    end

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS        ( RED_YELLOW_MS         )
  ) DUT (
    .clk_i      ( clk_i       ),
    .srst_i     ( srst_i      ),
    .cmd_type_i ( cmd_type_i  ),
    .cmd_valid_i( cmd_valid_i ),
    .cmd_data_i ( cmd_data_i  ),

    .red_o      ( red_o       ),
    .yellow_o   ( yellow_o    ),
    .green_o    ( green_o     )
  );

  task reset();
    srst_i <= 1'b1;
    repeat(2) @ ( posedge clk_i );
    if ( red_o != '0 || yellow_o != '0 || green_o != '0 )
      begin
        $error("reset failed :(");
        $stop();
      end
    srst_i <= '0;
  endtask

  task automatic cmd_type_set( input logic [2:0] code );
    cmd_type_i <= code;
    cmd_valid_i <= 1'b1;
    @( posedge clk_i );
    cmd_valid_i <= '0;
    @ ( posedge clk_i );
  endtask

  int red_ticks;
  int yellow_ticks;
  int green_ticks;

  task automatic set_time_for_red( input logic [15:0] data );
    cmd_data_i <= data;
    cmd_type_set( 3'd4 );
    red_ticks = data * 2;
  endtask

  task automatic set_time_for_yellow( input logic [15:0] data );
    cmd_data_i <= data;
    cmd_type_set( 3'd5 );
    yellow_ticks = data * 2;
  endtask

  task automatic set_time_for_green( input logic [15:0] data );
    cmd_data_i <= data;
    cmd_type_set( 3'd3 );
    green_ticks = data * 2;
  endtask

  task automatic check_blinking();
    logic prev;
    repeat (BLINK_GREEN_TIME_TICK * 2)
      begin
        prev = green_o;
        wait_ticks( BLINK_HALF_PERIOD_TICKS );
        if (green_o == prev)
          begin
            $error("green blinking went wrong");
            $stop();
          end
      end
  endtask

  task automatic check_NOTRANSITION_S( input int n );
    logic prev;

    cmd_type_set( 3'd2 );
    repeat (n)
      begin
        prev = yellow_o;
        wait_ticks( BLINK_HALF_PERIOD_TICKS + 1 );
        if (yellow_o == prev)
          begin
            $error("yellow has to blink in NOTRANSITION_S");
            $stop();
          end
      end
    
  endtask

  task automatic check_colours(
    input logic exp_r,
    input logic exp_y,
    input logic exp_g
  );
    if ( red_o != exp_r )
      begin
        $error("RED - expected: %d, got: %d", exp_r, red_o);
        $stop();
      end
    if ( yellow_o != exp_y )
      begin
        $error("YELLOW - expected: %d, got: %d", exp_y, yellow_o);
        $stop();
      end
    if ( green_o != exp_g )
      begin
        $error("GREEN - expected: %d, got: %d", exp_g, green_o);
        $stop();
      end
  endtask

  task automatic check_turn_off();
    cmd_type_set( 3'd1 );

    check_colours('0, '0, '0);
    wait_ticks(100);
    cmd_type_set( 3'd3 );
    check_colours('0, '0, '0);
  endtask

  task automatic set();
    cmd_type_set( 3'd2 );

    set_time_for_red(16'($urandom()));
    set_time_for_yellow(16'($urandom()));
    set_time_for_green(16'($urandom()));
    $display("time for red: %d \n time for yellow: %d \n time for green: %d", red_ticks, yellow_ticks, green_ticks);
  endtask

  task automatic wait_ticks( input int ticks );
    repeat ( ticks ) @ ( posedge clk_i );
  endtask

  task automatic check_colours_change( input int n );
    cmd_type_set( 3'd0 );
    repeat (n)
      begin
        @ (posedge clk_i);
        check_colours('1, '0, '0);

        wait_ticks( red_ticks );
        check_colours('1, '1, '0);

        wait_ticks( RED_YELLOW_TICKS );
        check_colours('0, '0, '1);

        wait_ticks( green_ticks );
        check_blinking();

        check_colours('0, '1, '0);
        wait_ticks( yellow_ticks );
      end
  endtask

  initial
    begin
      cmd_data_i  <= '0;
      cmd_valid_i <= '0;
      cmd_type_i  <= '0;
      @ ( posedge clk_i );
      reset();
      @ ( posedge clk_i );

      
      check_turn_off();
      $display("turn_off_test passed");
      set();

      check_colours_change(1);
      $display("colours_changing_test passed");

      check_NOTRANSITION_S(10);
      $display("yellow_blinking_test passed");

      check_turn_off();
      $display("the simulation is complete. all tests passed");
      $finish();
    end

endmodule