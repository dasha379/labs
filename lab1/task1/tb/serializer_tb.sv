`timescale 1ns / 1ps

module serializer_tb;
  localparam   width = 16;
  localparam   w_index = $clog2(width);
  logic        clk;
  logic        rst;

  logic [width - 1:0]   parallel_data;
  logic [w_index - 1:0] data_mod;
  logic                 parallel_valid;

  logic        serial_data;
  logic        serial_valid;
  logic        busy;

  logic [width - 1:0] array;
  logic               serial_expected;
  int                 param, flag;

  serializer DUT (
    .clk_i(clk),
    .srst_i(rst),
    .data_i(parallel_data),
    .data_mod_i(data_mod),
    .data_val_i(parallel_valid),
    .ser_data_o(serial_data),
    .ser_data_val_o(serial_valid),
    .busy_o(busy)
  );

  initial forever #5 clk = ~clk;

  task reset();
    rst <= 1'b1;

    repeat (2) @ (posedge clk);
    if (serial_data != 1'b0 || serial_valid != 1'b0 || busy != 1'b0)
      $error("reset failed");

    rst <= 1'b0;
  endtask

  function int calculate_valid_bits( input [w_index - 1:0] data_mod );
    case( data_mod )
      w_index'(0): return 16;
      w_index'(1): return 0;
      w_index'(2): return 0;
      default: return data_mod;
    endcase
  endfunction

  function [width - 1:0] create_array( input [width - 1:0] data );
    logic [width - 1:0] storage;
    for ( int i = 0; i < width; ++i )
      storage[i] = data[width - 1 - i];
    return storage;
  endfunction

  task form_serial_data( input int param );
    array = create_array(parallel_data);

    for (int i = 0; i < param; ++i)
      begin
        serial_expected = array[i];
        @(posedge clk);
        if (serial_data != serial_expected && serial_valid)
          begin
            $error("expected = %b , got = %b", serial_expected, serial_data);
            $finish(1);
          end
      end
    #1;
    if (serial_valid)
      $error("serial_valid signal should be 0 after the end of the process");
    if (busy)
      $error("busy signal should be 0 after the end of the process");
  endtask

  task test
  (
    input [width - 1:0]   parallel_data_test,
    input [w_index - 1:0] data_mod_test
  );
    { parallel_data, data_mod } <= { parallel_data_test, data_mod_test };
    param = calculate_valid_bits(data_mod_test);

    parallel_valid <= 1'b1;
    flag = 1;
    @(posedge clk);
    parallel_valid <= 1'b0;
    
    if (flag == 1) begin
      form_serial_data(param);
      flag = 0;
    end
    else
      if ( serial_valid != parallel_valid )
        $error("valid signal works wrong :( ");
    @(posedge clk);
    if (param > 0)
      wait(busy == 1'b0);

  endtask

  logic [width - 1: 0]  a;
  logic [w_index - 1:0] b;

  initial
    begin
      clk = 1'b0;
      parallel_data <= '0;
      data_mod <= '0;
      parallel_valid <= '0;

      reset();

      test(16'hFFFF, 4'b0010);
      test(16'hFFFF, 4'b0001);
      test(16'hFFFF, 4'b0000);
      test(16'd1, 4'b0010);
      test(16'd1, 4'b0001);
      test(16'd1, 4'b0000);
      test(16'd0, 4'b0000);

      for (int i = 0; i < 7; ++i)
        begin
            a = width'($urandom());
            b = w_index'($urandom());
            test(a, b);
        end
      $finish;
    end

endmodule