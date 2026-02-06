module traffic_lights_wr # (
  parameter BLINK_HALF_PERIOD_MS = 10000,
  parameter BLINK_GREEN_TIME_TICK = 100,
  parameter RED_YELLOW_MS = 9000
) (
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic [2:0]  cmd_type_i,
  input  logic        cmd_valid_i,
  input  logic [15:0] cmd_data_i,

  output logic        red_o,
  output logic        yellow_o,
  output logic        green_o
);

  logic        WRsrst_i;
  logic [2:0]  WRcmd_type_i;
  logic        WRcmd_valid_i;
  logic [15:0] WRcmd_data_i;

  logic        WRred_o;
  logic        WRyellow_o;
  logic        WRgreen_o;

  always_ff @ ( posedge clk_i )
    begin
      WRsrst_i      <= srst_i;
      WRcmd_type_i  <= cmd_type_i;
      WRcmd_valid_i <= cmd_valid_i;
      WRcmd_data_i  <= cmd_data_i;

      red_o         <= WRred_o;
      yellow_o      <= WRyellow_o;
      green_o       <= WRgreen_o;
    end

  traffic_lights #(
    .BLINK_HALF_PERIOD_MS ( BLINK_HALF_PERIOD_MS  ),
    .BLINK_GREEN_TIME_TICK( BLINK_GREEN_TIME_TICK ),
    .RED_YELLOW_MS        ( RED_YELLOW_MS         )
  ) WRAP (
    .clk_i      ( clk_i         ),
    .srst_i     ( WRsrst_i      ),
    .cmd_type_i ( WRcmd_type_i  ),
    .cmd_valid_i( WRcmd_valid_i ),
    .cmd_data_i ( WRcmd_data_i  ),

    .red_o      ( WRred_o       ),
    .yellow_o   ( WRyellow_o    ),
    .green_o    ( WRgreen_o     )
  );

endmodule