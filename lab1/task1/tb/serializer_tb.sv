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
  int                 param;

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

  initial
    begin
      clk = '0;
      forever #5 clk = ~clk;
    end

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

  task driver(
    input [width-1:0]   data,
    input [w_index-1:0] mod
  );
    wait(busy == '0);

    parallel_data <= data;
    data_mod <= mod;
    parallel_valid <= 1'b1;

    @(posedge clk);

    parallel_valid <= 1'b0;
    parallel_data <= 'x;
    data_mod <= 'x;

    repeat (param) @(posedge clk);
  endtask

  task test(
    input [width - 1:0]   data,
    input [w_index - 1:0] mod
  );
    array = create_array(data);
    param = calculate_valid_bits(mod);
    fork
      driver(data, mod);
      check();
    join
  endtask

  task check();
    automatic int bit_cnt = 0;

    if (param)
      begin
        wait(serial_valid == 1'b1);
        @(posedge clk);
        while (serial_valid == 1'b1)
          begin
            if (serial_data != array[bit_cnt])
              $error("expected %b, got %b", array[bit_cnt], serial_data);
            bit_cnt++;
            @(posedge clk);
          end

        if (bit_cnt != param)
          $error("received %d bits, expected %d bits", bit_cnt, param);
        if (serial_valid != '0)
          $error("serial_valid signal has to be 0 at the end of the process");
        if (busy != '0)
          $error("busy signal has to be 0 at the end of the process");
      end
  endtask

  initial
    begin
      parallel_data  <= '0;
      data_mod       <= '0;
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
            test(width'($urandom()), w_index'($urandom()));
        end
      $finish;
    end

endmodule