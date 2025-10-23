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
  
  task test
   (
	  input [1:0] td0, td1, td2, td3,
	  input [1:0] tdirection_i,
	  input [1:0] tdata 
	);
    { d0, d1, d2, d3, direction_i_tb } = { td0, td1, td2, td3, tdirection_i };
	 
	 #1ns;

	 if ( data_o_tb != tdata ) begin
	   $display("fail: expected %b got %b", tdata, data_o_tb);
		$finish(1);
	 end
  endtask
  
  initial begin
    test(2'b01, 2'b00, 2'b11, 2'b10, 0, 2'b01);
	 test(2'b01, 2'b00, 2'b11, 2'b10, 1, 2'b00);
	 test(2'b01, 2'b00, 2'b11, 2'b10, 2, 2'b11);
	 test(2'b01, 2'b00, 2'b11, 2'b10, 3, 2'b10);
	 
	 for (int j = 0; j < 10; j++) begin
		 for (int i = 0; i < 4; i++ ) begin
			d0 = $urandom_range(3);
			d1 = $urandom_range(3);
			d2 = $urandom_range(3);
			d3 = $urandom_range(3);
			direction_i_tb = i;
			
			case(direction_i_tb)
			  0: test(d0, d1, d2, d3, 0, d0);
			  1: test(d0, d1, d2, d3, 1, d1);
			  2: test(d0, d1, d2, d3, 2, d2);
			  3: test(d0, d1, d2, d3, 3, d3);
			endcase
		 end
	 end
    
	 $display("passed, 0 errors");
    $finish;
  end
  
endmodule