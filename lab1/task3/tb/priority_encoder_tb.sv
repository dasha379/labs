`timescale 1ns/1ps

module priority_encoder_tb #(parameter width = 8);
  logic                 clk_i;
  logic                 srst_i;
  logic [width - 1 : 0] data_i;
  logic                 data_val_i;
  logic [width - 1 : 0] data_left_o;
  logic [width - 1 : 0] data_right_o;
  logic                 data_val_o;

  priority_encoder #(.width(width)) DUT (.*);

  initial
    begin
      clk_i = '0;
      forever #5 clk_i = ~clk_i;
    end
  
  task reset();
    srst_i <= 1'b1;
    repeat (2) @ ( posedge clk_i );
    if (data_left_o != '0 || data_right_o != '0 || data_val_o != '0)
      $error("reset failed");
    srst_i <= '0;
  endtask

  typedef struct {
    logic [width - 1:0] l;
    logic [width - 1:0] r;
  } packet;

  mailbox#(packet) in_mbx = new();

  task driver();
    packet p;

    @( posedge clk_i );

    data_i     <= width'($urandom());
    data_val_i <= 1'($urandom());

    @( posedge clk_i );
    
    p.l = left(data_i, data_val_i);
    p.r = right(data_i, data_val_i);
    in_mbx.put(p);
    if (data_val_i)
      $strobe("data = %b", data_i);
  endtask

  function automatic logic [width - 1 : 0] left(
    input logic [width - 1 : 0] data,
    input logic valid
  );
    logic [width - 1 : 0] left_;
    left_ = '0;
    for (int i = width - 1; i >= 0; i--)
      begin
        if ( valid )
          begin
            if ( data[i] == 1'b1 )
              begin
                left_[i] = 1'b1;
                return left_;
              end
          end
      end
    return left_;
  endfunction

  function automatic logic [width - 1 : 0] right(
    input logic [width - 1 : 0] data,
    input logic valid
  );
    logic [width - 1 : 0] right_;
    right_ = '0;
    for (int i = 0; i < width; i++)
      begin
        if ( valid )
          begin
            if ( data[i] == 1'b1 )
              begin
                right_[i] = 1'b1;
                return right_;
              end
          end
      end
    return right_;
  endfunction

  task check();
    packet in_p;
    in_mbx.get(in_p);

    @( posedge clk_i );

    if ( data_val_o )
      begin
        if (data_left_o != in_p.l)
          $error("LEFT: expected - %b, got - %b", in_p.l, data_left_o);
        else
          $display("PASSED left = %b", data_left_o);
        if (data_right_o != in_p.r)
          $error("RIGHT: expected - %b, got - %b", in_p.r, data_right_o);
        else
          $display("PASSED right = %b", data_right_o);
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
      data_i <= '0;
      data_val_i <= '0;

      reset();

      @( posedge clk_i );

      repeat (10) test();
      reset();
      repeat (5) test();

      $finish;
    end

  initial
    begin
      repeat (10000) @ (posedge clk_i);
      $stop();
    end
endmodule
