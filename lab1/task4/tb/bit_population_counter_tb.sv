`timescale 1ns/1ps

module bit_population_counter_tb;
  parameter int WIDTH = 24;

  logic                     clk_i;
  logic                     srst_i;
  logic [WIDTH - 1 : 0]     data_i;
  logic                     data_val_i;
  logic [$clog2(WIDTH) : 0] data_o;
  logic                     data_val_o;

  bit_population_counter #(
    .WIDTH     ( WIDTH     )
  ) DUT (
    .clk_i     ( clk_i     ),
    .srst_i    ( srst_i    ),
    .data_i    ( data_i    ),
    .data_val_i( data_val_i),
    .data_o    ( data_o    ),
    .data_val_o( data_val_o)
  );

  initial
    begin
      clk_i = '0;
      forever #5 clk_i = ~clk_i;
    end

  task reset();
    srst_i <= 1'b1;
    repeat (2) @(posedge clk_i);
    if (data_o != '0 || data_val_o != '0)
      $error("reset failed");
    srst_i <= 1'b0;
  endtask

  typedef struct {
    logic                   valid;
    logic [$clog2(WIDTH):0] cnt;
  } packet;

  mailbox#(packet) in_mbx = new();

  task driver();
    packet p;
    logic [WIDTH - 1 : 0] data_i_to_pass;

    @(posedge clk_i);

    data_i_to_pass = WIDTH'($urandom());
    data_i         <= data_i_to_pass;
    data_val_i     <= 1'($urandom());

    @(posedge clk_i);

    p.valid = data_val_i;
    p.cnt   = $countones(data_i_to_pass);
    in_mbx.put(p);

  endtask

  int success_count = 0;

  task check();
    packet in_p;
    in_mbx.get(in_p);

    @(posedge clk_i);

    if (data_val_o != in_p.valid)
      begin
        $error("incorrect valid signal - expected : %b, got : %b", in_p.valid, data_val_o);
        $stop();
      end

    if (data_val_o)
      begin
        if (data_o != in_p.cnt)
          begin
            $error("expected : %d, got : %d", in_p.cnt, data_o);
            $stop();
          end
        else
          success_count += 1;
      end
  endtask

  task test();
    fork
      driver();
      check();
    join
  endtask

  initial
    begin
      data_i     <= '0;
      data_val_i <= '0;

      reset();

      @(posedge clk_i);

      repeat(25) test();
      $display("simulation is over. passed %d tests", success_count);
      $finish;

    end

  initial
    begin
      repeat (10000) @(posedge clk_i);
      $display("timeout occured");
      $stop();
    end

endmodule