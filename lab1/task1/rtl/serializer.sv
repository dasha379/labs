module serializer(
  input        clk_i,
  input        srst_i,
  input [15:0] data_i,
  input [3:0]  data_mod_i,
  input        data_val_i,
  output logic ser_data_o,
  output logic ser_data_val_o,
  output logic busy_o
);

  logic [4:0]  counter;
  logic [15:0] shift;
  logic [4:0]  param;

  always_ff @ ( posedge clk_i )
    begin
      if ( srst_i )
        begin
          ser_data_o     <= 1'b0;
          ser_data_val_o <= 1'b0;
          busy_o         <= 1'b0;
          counter        <= 4'b0;
          shift          <= 16'b0;
          param          <= 5'b0;
        end
      else
        begin
          if ( data_val_i )
            begin
              if ( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
                begin
                  ser_data_o     <= data_i[15];
                  ser_data_val_o <= 1'b1;
                  shift          <= data_i;
                  counter        <= 5'b1;
                  busy_o         <= 1'b1;
                  param          <= (data_mod_i == 4'b0) ? 16 : data_mod_i;
                end
            end
          else
            begin
              if ( data_mod_i != 4'b0001 && data_mod_i != 4'b0010 )
                begin
                  if ( busy_o && counter < param )
                    begin
                        ser_data_o     <= shift[14];
                        ser_data_val_o <= 1'b1;
                        shift          <= shift << 1;
                        counter        <= counter + 1'b1;
                        busy_o         <= 1'b1;
                    end
                  else
                    begin
                      ser_data_o     <= 1'b0;
                      ser_data_val_o <= 1'b0;
                      busy_o         <= 1'b0;
                      counter        <= 5'b0;
                    end
                end
            end
        end
    end

endmodule