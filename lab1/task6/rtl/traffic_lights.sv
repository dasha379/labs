module traffic_lights #(
  parameter BLINK_HALF_PERIOD_MS = 100,
  parameter BLINK_GREEN_TIME_TICK = 100,
  parameter RED_YELLOW_MS = 90
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

  localparam CLK_FREQ_HZ = 2000;
  localparam BLINK_HALF_PERIOD_TICKS = BLINK_HALF_PERIOD_MS * 2;
  localparam BLINK_PERIOD_TICKS = BLINK_HALF_PERIOD_TICKS * 2;
  localparam BLINK_GREEN_TICKS = 2 * BLINK_HALF_PERIOD_TICKS * BLINK_GREEN_TIME_TICK;
  localparam RED_YELLOW_TICKS = RED_YELLOW_MS * 2;

  typedef enum logic [2:0] {
    OFF_S,
    NOTRANSITION_S,
    GREEN_S,
    YELLOW_S,
    RED_S,
    RED_YELLOW_S,
    GREEN_BLINK_S
  } state_e;

  state_e state, next_state;

  logic [31:0] green_ticks;
  logic [31:0] green_ticks_cnt;
  logic [31:0] yellow_ticks;
  logic [31:0] yellow_ticks_cnt;
  logic [31:0] red_ticks;
  logic [31:0] red_ticks_cnt;

  logic red_expired, green_expired, yellow_expired, red_yellow_expired, green_blink_expired;

  always_ff @ (posedge clk_i)
    if ( srst_i ) green_ticks <= 32'd100;
    else if ( cmd_valid_i && cmd_type_i == 3'd3 ) green_ticks <= cmd_data_i * 2;
  
  always_ff @ (posedge clk_i)
    if ( srst_i ) green_ticks_cnt <= '0;
    else if ( state == GREEN_S )
      green_ticks_cnt <= green_ticks_cnt + 1'b1;
    else green_ticks_cnt <= '0;

  always_ff @ (posedge clk_i)
    if ( srst_i ) red_ticks <= 32'd100;
    else if ( cmd_valid_i && cmd_type_i == 3'd4 ) red_ticks <= cmd_data_i * 2;

  always_ff @ (posedge clk_i)
    if ( srst_i ) red_ticks_cnt <= '0;
    else if ( state == RED_S )
      red_ticks_cnt <= red_ticks_cnt + 1'b1;
    else red_ticks_cnt <= '0;
  
  always_ff @ (posedge clk_i)
    if ( srst_i ) yellow_ticks <= 32'd100;
    else if ( cmd_valid_i && cmd_type_i == 3'd5 ) yellow_ticks <= cmd_data_i * 2;
  
  always_ff @ (posedge clk_i)
    if ( srst_i ) yellow_ticks_cnt <= '0;
    else if ( state == YELLOW_S )
      yellow_ticks_cnt <= yellow_ticks_cnt + 1'b1;
    else yellow_ticks_cnt <= '0;

  logic [31:0] red_yellow_cnt;

  always_ff @ (posedge clk_i)
    if ( srst_i ) red_yellow_cnt <= '0;
    else if ( state == RED_YELLOW_S )
      red_yellow_cnt <= red_yellow_cnt + 1'b1;
    else red_yellow_cnt <= '0;

  logic [31:0] green_blink_cnt;

  always_ff @ (posedge clk_i)
    if ( srst_i ) green_blink_cnt <= '0;
    else if ( state == GREEN_BLINK_S )
      green_blink_cnt <= green_blink_cnt + 1'b1;
    else green_blink_cnt <= '0;

  logic [31:0] blink_cnt;

  always_ff @ ( posedge clk_i )
    if ( srst_i )
      blink_cnt <= '0;
    else if (( state == GREEN_BLINK_S || state == NOTRANSITION_S ) && blink_cnt < BLINK_PERIOD_TICKS - 1 )
      blink_cnt <= blink_cnt + 32'd1;
    else blink_cnt <= '0;

  logic stable;

  always_ff @ (posedge clk_i)
    if (srst_i) stable <= '0;
    else if (state == GREEN_BLINK_S || state == NOTRANSITION_S) stable <= (blink_cnt < BLINK_HALF_PERIOD_TICKS);
    else stable <= '0;

   always_ff @ ( posedge clk_i )
    if (srst_i) begin
      red_expired         <= '0;
      red_yellow_expired  <= '0;
      green_expired       <= '0;
      green_blink_expired <= '0;
      yellow_expired      <= '0;
    end else begin
      red_expired         <= (state == RED_S)         && (red_ticks_cnt    == red_ticks - 1);
      red_yellow_expired  <= (state == RED_YELLOW_S)  && (red_yellow_cnt   == RED_YELLOW_TICKS - 1);
      green_expired       <= (state == GREEN_S)       && (green_ticks_cnt  == green_ticks - 1);
      green_blink_expired <= (state == GREEN_BLINK_S) && (green_blink_cnt  == BLINK_GREEN_TICKS - 1);
      yellow_expired      <= (state == YELLOW_S)      && (yellow_ticks_cnt == yellow_ticks - 1);
    end

  always_ff @ ( posedge clk_i )
    if ( srst_i ) state <= RED_S;
    else state <= next_state;

  always_comb
    begin
      next_state = state;
      if ( cmd_valid_i )
        case( cmd_type_i )
          3'd0:    if ( state == OFF_S || state == NOTRANSITION_S ) next_state = RED_S;
          3'd1:    next_state = OFF_S;
          3'd2:    next_state = NOTRANSITION_S;
          default: next_state = state;
        endcase
      else
        case( state )
          RED_S:         if (red_expired)         next_state = RED_YELLOW_S;
          RED_YELLOW_S:  if (red_yellow_expired)  next_state = GREEN_S;
          GREEN_S:       if (green_expired)       next_state = GREEN_BLINK_S;
          GREEN_BLINK_S: if (green_blink_expired) next_state = YELLOW_S;
          YELLOW_S:      if (yellow_expired)      next_state = RED_S;
          default:                                next_state = state;
        endcase
    end

  assign red_o = (state == RED_S || state == RED_YELLOW_S);
  assign yellow_o = (state == YELLOW_S || state == RED_YELLOW_S || ( state == NOTRANSITION_S && stable ));
  assign green_o = (state == GREEN_S || ( state == GREEN_BLINK_S && stable ));

endmodule