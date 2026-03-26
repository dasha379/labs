`timescale 1ns/1ps

module sorting_tb;
  localparam DWIDTH = 8;
  localparam AWIDTH = 8;
  localparam WORDS = 1 << AWIDTH - 1;
  
  logic                  clk_i;
  logic                  srst_i;
  logic [DWIDTH - 1 : 0] snk_data_i;
  logic                  snk_startofpacket_i;
  logic                  snk_endofpacket_i;
  logic                  snk_valid_i;

  logic                  snk_ready_o;
  logic [DWIDTH - 1 : 0] src_data_o;
  logic                  src_startofpacket_o;
  logic                  src_endofpacket_o;
  logic                  src_valid_o;
  logic                  src_ready_i;

  initial
    begin
      clk_i = '0;
      forever #5 clk_i = ~clk_i;
    end

  task reset();
    srst_i <= '1;
    repeat (2) @ (posedge clk_i);
    srst_i <= '0;
  endtask
  
  sorting #(
    .DWIDTH     (DWIDTH),
    .MAX_PKT_LEN(WORDS)
  ) DUT (
    .clk_i              (clk_i),
    .srst_i             (srst_i),
    .snk_data_i         (snk_data_i),
    .snk_startofpacket_i(snk_startofpacket_i),
    .snk_endofpacket_i  (snk_endofpacket_i),
    .snk_valid_i        (snk_valid_i),

    .snk_ready_o        (snk_ready_o),
    .src_data_o         (src_data_o),
    .src_startofpacket_o(src_startofpacket_o),
    .src_endofpacket_o  (src_endofpacket_o),
    .src_valid_o        (src_valid_o),

    .src_ready_i        (src_ready_i)
  );

  typedef struct {
    logic [DWIDTH - 1 : 0] data [];
    logic [AWIDTH - 1 : 0] size;
  } packet;

  task automatic wait_between_packets(logic [AWIDTH - 1:0] size);

    repeat (size * size)
      begin
        @(posedge clk_i);
        if (snk_ready_o)
          return;
      end

  endtask

  task automatic generate_data();
    packet p_in;
    repeat(5)
      begin
        p_in.size = 10;
        p_in.data = new[p_in.size];
        for (int i = 0; i < p_in.size; ++i)
          p_in.data[i] = DWIDTH'($urandom());
        send(p_in);
        wait_between_packets(p_in.size);
      end
    sorted_order(15);
    reversed_order(15);
  endtask

  mailbox#(packet) in_m = new();

  task automatic send(packet p_in);
    wait(snk_ready_o == '1);

    if (src_valid_o == '1)
      $error("valid signal is 1, expected 0");

    for (int i = 0; i < p_in.size; ++i)
      begin
        @ (posedge clk_i);
        snk_data_i <= p_in.data[i];
        snk_valid_i <= '1;
        snk_startofpacket_i <= (i == 0);
        snk_endofpacket_i <= (i == p_in.size - 1);
      end

    in_m.put(p_in);
    
    @ (posedge clk_i);
    snk_data_i <= 'x;
    snk_endofpacket_i <= '0;
    snk_startofpacket_i <= '0;
    snk_valid_i <= '0;

  endtask

  task automatic sorted_order(int size);
    packet s_p;
    s_p.data = new[size];
    s_p.size = size;
    for (int i = 0; i < size; ++i)
      s_p.data[i] = i;
    send(s_p);
    wait_between_packets(size);
  endtask

  task automatic reversed_order(int size);
    packet s_p;
    s_p.data = new[size];
    s_p.size = size;
    for (int i = 0; i < size; ++i)
      s_p.data[i] = size - i - 1;
    send(s_p);
    wait_between_packets(size);
  endtask

  task automatic receive();
    packet out_p;
    int start, end_;
    int cnt;
    forever
      begin
        wait(src_startofpacket_o == '1);

        in_m.get(out_p);
        cnt += 1;
        $display("===packet %d===\n", cnt);

        for (int i = 0; i < out_p.size; ++i)
          $display("current array: %d", out_p.data[i]);
        out_p.data.sort();

        for (int i = 0; i < out_p.size; ++i)
          begin
            @(posedge clk_i);
            start = (i == 0);
            end_ = (i == out_p.size - 1);
            if (out_p.data[i] != src_data_o)
              $error("data is not correct. expected: %d, got: %d", out_p.data[i], src_data_o);
            
            $display("sorted %d member: %d", i, src_data_o);

            if (src_startofpacket_o != start)
              $error("start identification is wrong. expected: %d, got: %d", start, src_startofpacket_o);
            if (src_endofpacket_o != end_)
              $error("end identification is wrong. expected: %d, got: %d", end_, src_endofpacket_o);
          end
      end
  endtask

  task automatic test();
    fork
      generate_data();
      receive();
    join_any
  endtask

  initial
    begin
      snk_data_i          <= '0;
      snk_startofpacket_i <= '0;
      snk_endofpacket_i   <= '0;
      snk_valid_i         <= '0;
      src_ready_i         <= '1;

      reset();
      test();

      $display("simulation is complete =)");

      $finish();
    end

endmodule

