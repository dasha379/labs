module mux_tb;
  logic [1:0] d0, d1, d2, d3;
  logic [1:0] direction_i_tb;
  logic [1:0] data_o_tb;
  
  mux4_1 DUT (
    .data0_i    (d0            ),
	 .data1_i    (d1            ),
	 .data2_i    (d2            ),
	 .data3_i    (d3            ),
	 .direction_i(direction_i_tb),
	 .data_o     (data_o_tb     )
  );
  
  initial begin
    d0 = 2'b01; d1 = 2'b10; d2 = 2'b11; d3 = 2'b00;
    direction_i_tb = 2'b00;
	 #10ns;
	 if ( data_o_tb != d0 ) begin
      $display("error: expected %s got %s", d0, data_o_tb);
		$finish(1);
	 end
    
    direction_i_tb = 2'b01;
	 #10ns;
	 if ( data_o_tb != d1 ) begin
      $display("error: expected %s got %s", d1, data_o_tb);
		$finish(1);
	 end
   

    direction_i_tb = 2'b10;
	 #10ns;
	 if ( data_o_tb != d2 ) begin
      $display("error: expected %s got %s", d2, data_o_tb);
		$finish(1);
	 end

    direction_i_tb = 2'b11;
	 #10ns;
	 if ( data_o_tb != d3 ) begin
      $display("error: expected %s got %s", d3, data_o_tb);
		$finish(1);
	 end
    
	 $display("passed, 0 errors");
    $finish;
  end
  
endmodule