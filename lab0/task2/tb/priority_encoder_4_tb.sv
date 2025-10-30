typedef struct {
  logic [3:0] left;
  logic [3:0] right;
} data_result;

module priority_encoder_4_tb;
  logic [3:0] data_i_tb;
  logic       data_val_i_tb;
  logic [3:0] data_left_o_tb;
  logic [3:0] data_right_o_tb;
  logic       data_val_o_tb;

  logic [3:0] d;
  logic       v;

  priority_encoder_4 DUT (
    .data_i      ( data_i_tb       ),
    .data_val_i  ( data_val_i_tb   ),
    .data_left_o ( data_left_o_tb  ),
    .data_right_o( data_right_o_tb ),
    .data_val_o  ( data_val_o_tb   )
  );

  function data_result form_results( input logic [3:0] tdata );
    data_result res;

    casez( tdata )
      4'b1??? : res.left = 4'b1000;
      4'b01?? : res.left = 4'b0100;
      4'b001? : res.left = 4'b0010;
      4'b0001 : res.left = 4'b0001;
      default : res.left = 4'b0000;
    endcase

    casez( tdata )
      4'b???1 : res.right = 4'b0001;
      4'b??10 : res.right = 4'b0010;
      4'b?100 : res.right = 4'b0100;
      4'b1000 : res.right = 4'b1000;
      default : res.right = 4'b0000;
    endcase

    return res;

  endfunction

  task test
  (
    input logic [3:0] tdata,
    input logic       tdata_val_i
  );
    logic [3:0] tdata_left, tdata_right;
    logic tdata_val_o;
    data_result res;

    { data_i_tb, data_val_i_tb } = { tdata, tdata_val_i };

    #1ns;

    res = form_results( tdata );
    tdata_left  = res.left;
    tdata_right = res.right;
    tdata_val_o = tdata_val_i;

    if ( tdata_val_i )
      begin
        if ( tdata_right != data_right_o_tb )
          $error("expected: %b, got: %b", tdata_right, data_right_o_tb);
        if ( tdata_left != data_left_o_tb )
          $error("expected: %b, got: %b", tdata_left, data_left_o_tb);
      end
    if ( tdata_val_o != data_val_o_tb )
      $error("expected: %b, got: %b", tdata_val_o, data_val_o_tb);

  endtask

  initial begin
    test(4'b1111, 1);
    test(4'b0000, 1);
    test(4'b1111, 0);
    test(4'b0000, 0);

    // test which covers all the cases without $random
    d = 4'b0000;
    for ( int i = 0; i < 15; i++ ) begin
      d += 4'b1;
      test(d, 1);
      test(d, 0);
    end

    // 5 random iterations
    for ( int i = 0; i < 5; i++ ) begin
      d = $urandom_range(15);
      v = $urandom_range(1);
      test(d, v);
    end

    $display("simulation is over, 0 errors");
    $finish;
  end

endmodule