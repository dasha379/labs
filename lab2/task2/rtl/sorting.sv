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
  logic [AWIDTH - 1 : 0] rd_addr;
  logic [AWIDTH - 1 : 0] wr_addr;
  logic wr_en;
  assign wr_en = ( snk_valid_i && ( state == INPUT_S || (state == WAIT_S && snk_startofpacket_i) ) );

  always_ff @ (posedge clk_i)
    if ( srst_i )
      wr_addr <= '0;
    else
      if ( wr_en )
        wr_addr <= wr_addr + snk_valid_i;
      else if (state == WAIT_S)
        wr_addr <= '0;

  always_ff @ (posedge clk_i)
    if ( srst_i )
      rd_addr <= '0;
    else
      if ( state == OUTPUT_S )
        rd_addr <= rd_addr + AWIDTH'(1);
      else if (state == WAIT_S)
        rd_addr <= '0;

  always_ff @ (posedge clk_i)
    if ( srst_i )
      data_size <= '0;
    else if ( wr_en && snk_endofpacket_i)
      if (wr_addr > '0)
        data_size <= wr_addr + AWIDTH'(2);
      else
        data_size <= AWIDTH'(1);
  
  logic single;
  assign single = data_size == AWIDTH'(1);

  logic [AWIDTH - 1 : 0] a_addr;
  logic                  a_valid;
  logic [DWIDTH - 1 : 0] a_in;
  logic [DWIDTH - 1 : 0] a_out;

  logic [AWIDTH - 1 : 0] b_addr;
  logic                  b_valid;
  logic [DWIDTH - 1 : 0] b_in;
  logic [DWIDTH - 1 : 0] b_out;
  logic                  end_sort;

  logic [AWIDTH - 1 : 0] ram_addr;
  logic                  ram_we;
  logic [DWIDTH - 1 : 0] ram_data;
  
  always_comb begin
    case (state)
      WAIT_S: begin
        if (snk_startofpacket_i == '1)
          begin
            ram_addr = wr_addr;
            ram_we = wr_en;
            ram_data = snk_data_i;
          end
        else
          begin
            ram_addr = '0;
            ram_we = 1'b0;
            ram_data = '0;
          end
      end
      INPUT_S: begin
        ram_addr = wr_addr;
        ram_we = wr_en;
        ram_data = snk_data_i;
      end
      SORT_S: begin
        ram_addr = a_addr;
        ram_we = a_valid;
        ram_data = a_in;
      end
      OUTPUT_S: begin
        ram_addr = rd_addr;
        ram_we = 1'b0;
        ram_data = '0;
      end
      default: begin
        ram_addr = '0;
        ram_we = 1'b0;
        ram_data = '0;
      end
    endcase
  end

  true_dual_port_ram_single_clock #(
    .DATA_WIDTH(DWIDTH),
    .ADDR_WIDTH(AWIDTH)
  ) ram (
    .clk   (clk_i),
    .we_a  (ram_we),
    .we_b  (b_valid),
    .data_a(ram_data),
    .data_b(b_in),
    .addr_a(ram_addr),
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
        WAIT_S:   if (snk_valid_i && snk_endofpacket_i)        next_state = OUTPUT_S;
                  else if (snk_valid_i && snk_startofpacket_i) next_state = INPUT_S;
        INPUT_S:  if (snk_valid_i && snk_endofpacket_i)        next_state = SORT_S;
        SORT_S:   if (end_sort)                                next_state = OUTPUT_S;
        OUTPUT_S: if (rd_addr == data_size - AWIDTH'(1))       next_state = WAIT_S;
        default:                                               next_state = WAIT_S;
      endcase
    end

  assign src_data_o          = a_out;
  assign snk_ready_o         = state == WAIT_S;
  assign src_startofpacket_o = (state == OUTPUT_S) && (~single && rd_addr == AWIDTH'(1) || single && rd_addr == '0);
  assign src_endofpacket_o   = (state == OUTPUT_S) && (~single && rd_addr == data_size - AWIDTH'(1) || single && rd_addr == '0);
  assign src_valid_o         = (state == OUTPUT_S) && (rd_addr >= '0);

endmodule

