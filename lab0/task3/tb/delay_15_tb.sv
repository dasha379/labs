`timescale 1ns/1ps

module delay_15_tb;
  logic       clk;
  logic       rst;
  logic       data_i_tb;
  logic [3:0] data_delay_i_tb;
  logic       data_o_tb;

  logic data_cur;

  delay_15 DUT (
    .clk_i       ( clk             ),
    .rst_i       ( rst             ),
    .data_i      ( data_i_tb       ),
    .data_delay_i( data_delay_i_tb ),
    .data_o      ( data_o_tb       )
  );

  initial forever #5 clk = ~clk;

  task reset();
    rst = '1;
    repeat (2) @( posedge clk );
    rst = '0;
  endtask

  task test_delay();
    repeat (16) @ ( posedge clk );

    data_cur = data_i_tb;

    repeat (data_delay_i_tb) @ ( posedge clk );

    if ( data_o_tb != data_cur && ~rst )
      $error("expected %b, got %b, time = %0d", data_cur, data_o_tb, $time);
    else if ( data_o_tb != 1'b0 && rst )
      $error("expected 0, got %b", data_o_tb);
    else
      $display("PASSED: data_cur = %b, data_o_tb = %b, time = %0d", data_cur, data_o_tb, $time);

    repeat (5) @( posedge clk );
  endtask

  initial
    begin
      clk = 1'b0;
      data_i_tb = 1'b0;
      @( posedge clk );
      data_i_tb = 1'b1;
      data_cur = data_i_tb;

      reset();

      fork
        begin
          for (int i = 0; i < 10; ++i)
            begin
              repeat (20) @( posedge clk );
              reset();
            end
        end
        begin
          for (int i = 0; i < 250; ++i)
            begin
              data_i_tb = $urandom_range(1);
              @( posedge clk );
            end
        end
        begin
          data_delay_i_tb = 4'b0;
          test_delay();

          data_delay_i_tb = 4'd15;
          test_delay();

          for (int i = 0; i < 5; ++i)
            begin
              data_delay_i_tb = $urandom_range(15);
              test_delay();
            end
        end
      join

      $finish;
    end
endmodule