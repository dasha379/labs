module sorting #(
  parameter DWIDTH = 8,
  parameter MAX_PKT_LEN = 8
) (
  input  logic                  clk_i,
  input  logic                  srst_i,
  input  logic [DWIDTH - 1 : 0] snk_data_i,
  input  logic                  snk_startofpacket_i,
  input  logic                  snk_endofpacket_i,
  input  logic                  snk_valid_i,

  output logic                  snk_ready_o,
  output logic [DWIDTH - 1 : 0] src_data_o,
  output logic                  src_startofpacket_o,
  output logic                  src_endofpacket_o,
  output logic                  src_valid_o,

  input logic                   src_ready_i
);

  localparam AWIDTH = $clog2(MAX_PKT_LEN);

  typedef enum {
    WAIT_S,
    INPUT_S,
    SORT_S,
    OUTPUT_S
  } state_t;

  state_t state, next_state;

  logic [AWIDTH - 1 : 0] data_size;
  logic [AWIDTH - 1 : 0] addr;
  logic wr_en;
  assign wr_en = ( snk_valid_i && ( state == INPUT_S || state == WAIT_S && snk_startofpacket_i ) );

  always_ff @ (posedge clk_i)
    if ( srst_i )
      addr <= '0;
    else
      if ( state == INPUT_S || wr_en )
        addr <= addr + snk_valid_i;
      else if ( state == OUTPUT_S )
        addr <= addr + AWIDTH'(1);
      else
        addr <= '0;

  always_ff @ (posedge clk_i)
    if ( srst_i )
      data_size <= '0;
    else if ( wr_en && snk_endofpacket_i )
      data_size <= addr + AWIDTH'(1);
    // else if (state == WAIT_S)
    //   data_size <= '0;

  logic [AWIDTH - 1 : 0] a_addr;
  logic                  a_valid;
  logic [DWIDTH - 1 : 0] a_in;
  logic [DWIDTH - 1 : 0] a_out;

  logic [AWIDTH - 1 : 0] b_addr;
  logic                  b_valid;
  logic [DWIDTH - 1 : 0] b_in;
  logic [DWIDTH - 1 : 0] b_out;
  logic                  end_sort;

  true_dual_port_ram_single_clock #(
    .DATA_WIDTH(DWIDTH),
    .ADDR_WIDTH(AWIDTH)
  ) ram (
    .clk   (clk_i),
    .we_a  (state == SORT_S ? a_valid : wr_en),
    .we_b  (b_valid),
    .data_a(state == SORT_S ? a_in : snk_data_i),
    .data_b(b_in),
    .addr_a(state == SORT_S ? a_addr : addr),
    .addr_b(b_addr),
    .q_a   (a_out),
    .q_b   (b_out)
  );

  bubble # (
    .DWIDTH(DWIDTH),
    .AWIDTH(AWIDTH)
  ) sort (
    .clk_i    (clk_i),
    .srst_i   (srst_i || state == WAIT_S),
    .en       (state == SORT_S),
    .data_size(data_size),
    .a_in     (a_out),
    .b_in     (b_out),
    .a_addr   (a_addr),
    .b_addr   (b_addr),
    .a_valid  (a_valid),
    .b_valid  (b_valid),
    .a_out    (a_in),
    .b_out    (b_in),
    .end_sort (end_sort)
  );

  always_ff @ (posedge clk_i)
    if (srst_i)
      state <= WAIT_S;
    else
      state <= next_state;

  always_comb
    begin
      next_state = state;
      case(state)
        WAIT_S:   if (snk_valid_i && snk_startofpacket_i) next_state = INPUT_S;
        INPUT_S:  if (snk_valid_i && snk_endofpacket_i)   next_state = SORT_S;
        SORT_S:   if (end_sort)                           next_state = OUTPUT_S;
        OUTPUT_S: if (addr == data_size)                  next_state = WAIT_S;
        default:                                          next_state = WAIT_S;
      endcase
    end

  assign src_data_o          = a_out;
  assign snk_ready_o         = state == WAIT_S;
  assign src_startofpacket_o = (state == OUTPUT_S) && (addr == AWIDTH'(1));
  assign src_endofpacket_o   = (state == OUTPUT_S) && (addr == data_size);
  assign src_valid_o         = (state == OUTPUT_S) && (addr > '0);

endmodule