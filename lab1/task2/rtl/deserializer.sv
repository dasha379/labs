module deserializer(
  input         clk_i,
  input         srst_i,
  input         data_i,
  input         data_val_i,
  output logic [15:0] deser_data_o,
  output logic        deser_data_val_o
);

  logic [3:0] counter;

  always_ff @ ( posedge clk_i )
    begin
      if ( srst_i )
        counter <= 4'd0;
      else
        begin
          if ( data_val_i )
            if ( counter <= 4'd15 )
              counter <= counter + 1'd1;
            else
              counter <= 4'd0;
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if ( srst_i )
        deser_data_o <= '0;
      else
        if ( data_val_i )
          if (counter <= 4'd15)
            deser_data_o[15 - counter] <= data_i;
    end

  always_ff @ ( posedge clk_i )
    begin
      if( srst_i )
        deser_data_val_o <= '0;
      else
        deser_data_val_o <= data_val_i && (counter == 4'd15);
    end

endmodule