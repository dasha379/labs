`timescale 1ns/1ps

module deserializer_tb;
  localparam            width = 16;
  localparam            w_index = $clog2(width);

  logic                 clk_i;
  logic                 srst_i;
  logic                 data_i;
  logic                 data_val_i;

  logic [width - 1 : 0] deser_data_o;
  logic                 deser_data_val_o;

  deserializer DUT (.*);

  initial
    begin
      clk_i = '0;
      forever #5 clk_i = ~clk_i;
    end

  task reset();
    srst_i <= 1'b1;
    repeat (2) @ ( posedge clk_i );
    if ( deser_data_o != '0 && deser_data_val_o != '0 )
      $error("%0t reset check failed", $time());
    srst_i <= 1'b0;
  endtask

  logic [w_index - 1 : 0] counter;
  int                     flag;
  logic [width - 1 : 0]   queue;

  task driver();
    @(posedge clk_i);

    data_i <= 1'($urandom());
    data_val_i <= 1'($urandom());

  endtask

  task gen_array();
    @(posedge clk_i);
    if ( data_val_i )
      begin
        if (counter <= 4'd15)
          begin
            queue[width - 1 - counter] <= data_i;
            counter <= counter + 1'b1;
            flag <= counter + 1;
            //$strobe($time(), queue[width - 1 - counter], width - 1 - counter);
          end
        else
          begin
            counter <= '0;
          end
      end
  endtask

  logic [width - 1 : 0] deser_data_expected;

  task check();
    if ( deser_data_val_o )
      begin
        if ( flag < width )
          $error("%0t received less bits : %d", $time(), counter);
        else
          begin
            for (int i = 0; i < width; ++i)
              begin
                deser_data_expected[i] = queue[i];
              end
            if ( deser_data_o != deser_data_expected )
              $error("%0t expected %b, got %b", $time(), deser_data_expected, deser_data_o);
          end
      end
  endtask

  task test();
    fork
      driver();
      gen_array();
      check();
    join
  endtask

  initial
    begin
      data_i     <= '0;
      data_val_i <= '0;
      counter    <= '0;

      reset();

      @(posedge clk_i);
      repeat(120) begin
        test();
      end
      $finish;
    end

  initial
    begin
      repeat (10000) @ (posedge clk_i);
      $stop();
    end
endmodule