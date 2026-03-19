`timescale 1ns/1ps

module fifo_tb;
  parameter DWIDTH = 16;
  parameter AWIDTH = 4;
  parameter SHOWAHEAD = 1;
  parameter ALMOST_FULL_VALUE = (1 << AWIDTH) - 4;
  parameter ALMOST_EMPTY_VALUE = 4;
  parameter REGISTER_OUTPUT = 0;

  localparam DEPTH = 1 << AWIDTH;

  logic                  clk_i;
  logic                  srst_i;
  logic [DWIDTH - 1 : 0] data_i;
  logic                  wrreq_i;
  logic                  rdreq_i;

  logic [DWIDTH - 1 : 0] q_o;
  logic                  empty_o;
  logic                  full_o;
  logic [AWIDTH : 0]     usedw_o;
  logic                  almost_empty_o;
  logic                  almost_full_o;

  initial
    begin
      clk_i = '0;
      forever #5 clk_i = ~clk_i;
    end

  fifo #(
    .DWIDTH            (DWIDTH),
    .AWIDTH            (AWIDTH),
    .SHOWAHEAD         (SHOWAHEAD),
    .ALMOST_FULL_VALUE (ALMOST_FULL_VALUE),
    .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
    .REGISTER_OUTPUT   (REGISTER_OUTPUT)
  ) DUT (
    .clk_i         (clk_i),
    .srst_i        (srst_i),
    .data_i        (data_i),
    .wrreq_i       (wrreq_i),
    .rdreq_i       (rdreq_i),
    .q_o           (q_o),
    .empty_o       (empty_o),
    .full_o        (full_o),
    .usedw_o       (usedw_o),
    .almost_empty_o(almost_empty_o),
    .almost_full_o (almost_full_o)
  );

  logic [DWIDTH - 1 : 0] golden_q_o;
  logic                  golden_empty_o;
  logic                  golden_full_o;
  logic [AWIDTH - 1 : 0] golden_usedw_o;
  logic                  golden_almost_empty_o;
  logic                  golden_almost_full_o;

  scfifo #(
    .lpm_width               ( DWIDTH ),
    .lpm_widthu              ( AWIDTH ),
    .lpm_numwords            ( 2 ** AWIDTH ),
    .lpm_showahead           ( "ON" ),
    .lpm_type                ( "scfifo" ),
    .lpm_hint                ( "RAM_BLOCK_TYPE=M10K" ),
    .intended_device_family  ( "Cyclone V" ),
    .underflow_checking      ( "ON" ),
    .overflow_checking       ( "ON" ),
    .allow_rwcycle_when_full ( "OFF" ),
    .use_eab                 ( "ON" ),
    .add_ram_output_register ( "OFF" ),
    .almost_full_value       ( ALMOST_FULL_VALUE ),
    .almost_empty_value      ( ALMOST_EMPTY_VALUE ),
    .maximum_depth           ( 0 ),
    .enable_ecc              ( "FALSE" )
  ) golden_model (
    .clock       (clk_i),
    .sclr        (srst_i),
    .data        (data_i),
    .wrreq       (wrreq_i),
    .rdreq       (rdreq_i),
    .q           (golden_q_o),
    .empty       (golden_empty_o),
    .full        (golden_full_o),
    .usedw       (golden_usedw_o),
    .almost_empty(golden_almost_empty_o),
    .almost_full (golden_almost_full_o),
    .aclr(),
    .eccstatus()
  );

  task reset();
    srst_i <= '1;
    repeat (2) @ ( posedge clk_i );
    srst_i <= '0;
  endtask

  task automatic generate_data(int num_tests);
    repeat(num_tests)
      begin
        @ ( posedge clk_i );
        data_i <= DWIDTH'($urandom());
      end
  endtask

  task automatic tests(int num_tests, int w, int r, const ref full, const ref empty);
    repeat(num_tests)
      begin
        @(posedge clk_i);
        wrreq_i <= '0;
        rdreq_i <= '0;
        if (!full && $urandom_range(1, 50) <= w)
          wrreq_i <= '1;
        if (!empty && $urandom_range(1, 50) <= r)
          rdreq_i <= '1;
      end
  endtask

  int err;

  task automatic check(int num_tests);
    repeat(num_tests)
      begin
        @ ( posedge clk_i );
        err = 0;

        if (q_o !== golden_q_o)
          begin
            $error("read data expected: %d, got: %d", golden_q_o, q_o);
            err += 1;
          end
        if (empty_o !== golden_empty_o)
          begin
            $error("empty signal expected: %d, got: %d", golden_empty_o, empty_o);
            err += 1;
          end
        if (full_o !== golden_full_o)
          begin
            $error("full signal expected: %d, got: %d", golden_full_o, full_o);
            err += 1;
          end
        if (usedw_o[AWIDTH-1:0] !== golden_usedw_o)
          begin
            $error("used words amount expected: %d, got: %d", golden_usedw_o, usedw_o);
            err += 1;
          end
        if (almost_full_o !== golden_almost_full_o)
          begin
            $error("almost_full signal expected: %d, got: %d", golden_almost_full_o, almost_full_o);
            err += 1;
          end
        if (almost_empty_o !== golden_almost_empty_o)
          begin
            $error("almost_empty signal expected: %d, got: %d", golden_almost_empty_o, almost_empty_o);
            err += 1;
          end
      end

  endtask

  task automatic test(int num_tests);
    int total = 3*num_tests + 2*DEPTH + 10;
    fork
      generate_data(total);
      check(total);
      begin
        tests(DEPTH+10, 50, 0, golden_full_o, golden_empty_o);
        tests(DEPTH, 0, 50, golden_full_o, golden_empty_o);
        tests(num_tests, 25, 25, golden_full_o, golden_empty_o);
        tests(num_tests, 10, 40, golden_full_o, golden_empty_o); // больше чтения
        tests(num_tests, 40, 5, golden_full_o, golden_empty_o); // больше записей
      end
    join_any
  endtask

  initial
    begin
      automatic int num_tests = 50;
      data_i  <= '0;
      wrreq_i <= '0;
      rdreq_i <= '0;

      reset();
      @ (posedge clk_i);
      test(num_tests);
      $display("simulation is complete. errors occured - %d", err);
      $finish();
    end
  
  initial
    begin
      repeat (10000) @ (posedge clk_i);
      $display("timeout");
      $stop();
    end
endmodule