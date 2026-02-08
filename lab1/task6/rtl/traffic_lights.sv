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

  state_e state, next;

  logic [31:0] green_ticks;
  logic [31:0] yellow_ticks;
  logic [31:0] red_ticks;

  always_ff @ (posedge clk_i)
    if ( srst_i ) green_ticks <= '0;
    else if ( cmd_type_i == 3'd3 ) green_ticks <= cmd_data_i * 2;

  always_ff @ (posedge clk_i)
    if ( srst_i ) red_ticks <= '0;
    else if ( cmd_type_i == 3'd4 ) red_ticks <= cmd_data_i * 2;
  
  always_ff @ (posedge clk_i)
    if ( srst_i ) yellow_ticks <= '0;
    else if ( cmd_type_i == 3'd5 ) yellow_ticks <= cmd_data_i * 2;

  logic [31:0] blink_cnt;
  logic [31:0] state_timer;
  logic        stable, perehod, flag;
  assign perehod = flag || cmd_valid_i;

  always_ff @ ( posedge clk_i )
    if ( srst_i ) state_timer <= '0;
    else
      if ( state != next && perehod )
        case( next )
          RED_S:         state_timer <= red_ticks - 1;
          RED_YELLOW_S:  state_timer <= RED_YELLOW_TICKS - 1;
          GREEN_S:       state_timer <= green_ticks - 1;
          YELLOW_S:      state_timer <= yellow_ticks - 1;
          GREEN_BLINK_S: state_timer <= BLINK_GREEN_TICKS - 1;
          default: ;
        endcase
      else if ( state_timer > 32'd0 )
        state_timer <= state_timer - 32'd1;

  always_ff @ ( posedge clk_i )
    if (srst_i) flag <= '0;
    else flag <= (state_timer == 32'd1);

  always_ff @ ( posedge clk_i )
    if ( srst_i )
      blink_cnt <= '0;
    else if ( perehod )
      blink_cnt <= '0;
    else if ( state == GREEN_BLINK_S || state == NOTRANSITION_S )
        if ( blink_cnt < BLINK_HALF_PERIOD_TICKS - 1)
          blink_cnt <= blink_cnt + 32'd1;
        else
          blink_cnt <= '0;

  always_ff @ ( posedge clk_i )
    if ( srst_i )
      stable <= '0;
    else if ( perehod )
      stable <= '0;
    else if ( blink_cnt == BLINK_HALF_PERIOD_TICKS - 1 )
      stable <= ~stable;

  always_ff @ ( posedge clk_i )
    if ( srst_i ) state <= RED_S;
    else if ( perehod ) state <= next;

  always_comb
    begin
      next = state;
      if ( cmd_valid_i )
        case( cmd_type_i )
          3'd0:    next = RED_S;
          3'd1:    next = OFF_S;
          3'd2:    next = NOTRANSITION_S;
          default: next = state;
        endcase
      else
        case( state )
          RED_S:         next = RED_YELLOW_S;
          RED_YELLOW_S:  next = GREEN_S;
          GREEN_S:       next = GREEN_BLINK_S;
          GREEN_BLINK_S: next = YELLOW_S;
          YELLOW_S:      next = RED_S;
          default:       next = state;
        endcase
    end

  always_ff @ ( posedge clk_i )
    if ( srst_i ) red_o <= '0;
    else if (cmd_type_i != 3'd1) red_o <= ( state == RED_S || state == RED_YELLOW_S );
    else red_o <= '0;

  always_ff @ ( posedge clk_i )
    if ( srst_i ) yellow_o <= '0;
    else if (cmd_type_i != 3'd1) yellow_o <= ( state == YELLOW_S || state == RED_YELLOW_S || state == NOTRANSITION_S && stable );
    else yellow_o <= '0;

  always_ff @ ( posedge clk_i )
    if ( srst_i ) green_o <= '0;
    else if (cmd_type_i != 3'd1) green_o <= ( state == GREEN_S || state == GREEN_BLINK_S && stable );
    else green_o <= '0;
endmodule