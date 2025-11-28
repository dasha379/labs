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

  int          counter;
  logic [15:0] shift;
  int          param;

  always @ (*)
    begin
      case( data_mod_i )
        0: param = 16;
        1: param = 0;
        2: param = 0;
        default: param = data_mod_i;
      endcase
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
              if ( busy_o && counter <= param )
                shift <= shift << 1;
            end
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        counter = 0;
      else
        begin
          if ( data_val_i && param )
            counter = 1;
          else
            begin
              if ( busy_o && counter <= param )
                counter += 1;
              else
                counter = 0;
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
              if ( busy_o && counter <= param )
                ser_data_o <= shift[14];
              else
                ser_data_o <= '0;
            end
        end
    end

  always_ff @ ( posedge clk_i )
    begin
      if (srst_i)
        ser_data_val_o <= '0;
      else
        begin
          if ( data_val_i && param )
            ser_data_val_o <= '1;
          else
            begin
              if ( busy_o && counter <= param )
                ser_data_val_o <= '1;
              else
                ser_data_val_o <= '0;
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
            busy_o <= '1;
          else
            begin
              if ( busy_o && counter <= param )
                busy_o <= '1;
              else
                busy_o <= '0;
            end
        end
    end

endmodule