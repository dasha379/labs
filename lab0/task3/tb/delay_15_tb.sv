`timescale 1ns/1ps

module delay_15_tb;
  logic       clk;
  logic       rst;
  logic       data_i_tb;
  logic [3:0] data_delay_i_tb;
  logic       data_o_tb;

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

  task form_input();
    data_i_tb = 1'b0;
    @( posedge clk );
    data_i_tb = 1'b1;
    repeat(4) @( posedge clk );
    data_i_tb = 1'b0;
    repeat(2) @( posedge clk );
    data_i_tb = 1'b1;
  endtask

  task perform_shift();
    repeat (16) @ ( posedge clk );
    form_input();
    repeat(data_delay_i_tb + 1) @( posedge clk );
    if ( data_o_tb != data_i_tb && ~rst )
      $error("expected %b, got %b, time = %0d", data_i_tb, data_o_tb, $time);
    else if ( data_o_tb != 1'b0 && rst )
      $error("expected 0, got %b", data_o_tb);
    $strobe("data_i_tb = %b, data_o_tb = %b, time = %0d", data_i_tb, data_o_tb, $time);
  endtask

  initial
    begin
      clk = 1'b0;
      data_i_tb = 1'b0;
      @( posedge clk );
      data_i_tb = 1'b1;

      reset();
      data_delay_i_tb = 4'd15;
      perform_shift();

      repeat(5) @( posedge clk );

      reset();
      data_delay_i_tb = 4'd0;
      perform_shift();

      repeat(5) @( posedge clk );

      for (int i = 0; i < 3; ++i)
        begin
          reset();
          data_delay_i_tb = $urandom_range(15);
          perform_shift();
          repeat(5) @( posedge clk );
        end

      $display("PASSED");
      $finish;
    end
endmodule