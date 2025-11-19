`timescale 1ns / 1ps

module crc_16_ansi_tb;
  logic        clk;
  logic        rst;
  logic        data_i;
  logic [15:0] data_o;

  logic [15:0] expected_crc;

  crc_16_ansi DUT (
    .clk_i  ( clk    ),
    .rst_i  ( rst    ),
    .data_i ( data_i ),
    .data_o ( data_o )
  );

  initial forever #5 clk <= ~clk;

  task reset();
      rst <= '1;
      expected_crc <= 16'h0000;
      repeat (2) @ ( posedge clk );
      if ( data_o != 16'h0000 )
        $error("reset failed");
      rst <= '0;
  endtask

  function void form_crc( input data );
    if (expected_crc[15] ^ data)
      expected_crc <= (expected_crc << 1) ^ 16'h8005;
    else
      expected_crc <= expected_crc << 1;
  endfunction

  initial
    begin
      clk    <= 1'b0;
      data_i <= 1'b0;
      reset();

      fork
        begin
          for ( int i = 0; i < 50; ++i )
            begin
              @(posedge clk);
              data_i <= $urandom_range(1);
            end
        end
        begin
          for ( int i = 0; i < 50; ++i )
            begin
              @(posedge clk);
              if (!rst)
                begin
                  form_crc(data_i);

                  if (data_o != expected_crc)
                    $error("data_o = %h, expected_crc = %h", data_o, expected_crc);
                  //$strobe("data_o = %h, expected_crc = %h", data_o, expected_crc);
                end
            end
        end
      join

      $display("simulation is over =) ");
      $finish;
    end
endmodule