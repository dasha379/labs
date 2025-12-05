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

  logic [15:0] shift;
  logic [4:0]  param, counter;

  always_comb
    begin
      if ( data_val_i )
        begin
          case( data_mod_i )
            4'd0: param = 5'd16;
            4'd1: param = 5'd0;
            4'd2: param = 5'd0;
            default: param = data_mod_i;
          endcase
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        counter <= '0;
      else
        begin
          if ( data_val_i && param )
            counter <= 5'b1;
          else
            begin
              if ( busy_o )
                counter <= counter + 5'b00001;
              else
                counter <= '0;
            end
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        shift <= '0;
      else
        begin
          if ( data_val_i && param )
            shift <= data_i;
          else
            begin
              if ( busy_o )
                shift <= shift << 1;
            end
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        ser_data_o <= '0;
      else
        begin
          if ( data_val_i && param )
            ser_data_o <= data_i[15];
          else
            begin
              if ( busy_o && counter < param )
                ser_data_o <= shift[14];
              else
                ser_data_o <= '0;
            end
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        busy_o <= '0;
      else
        begin
          if ( data_val_i && param )
            busy_o <= 1'b1;
          else
            begin
              if ( busy_o && counter < param )
                busy_o <= 1'b1;
              else
                busy_o <= '0;
            end
        end
    end

  assign ser_data_val_o = busy_o;

endmodule