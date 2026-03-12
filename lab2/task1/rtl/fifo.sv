module fifo #(
  parameter DWIDTH = 16,
  parameter AWIDTH = 4,
  parameter SHOWAHEAD = 1,
  parameter ALMOST_FULL_VALUE = (1 << AWIDTH) - 4,
  parameter ALMOST_EMPTY_VALUE = 4,
  parameter REGISTER_OUTPUT = 0
) (
  input  logic                  clk_i,
  input  logic                  srst_i,
  input  logic [DWIDTH - 1 : 0] data_i,
  input  logic                  wrreq_i,
  input  logic                  rdreq_i,

  output logic [DWIDTH - 1 : 0] q_o,
  output logic                  empty_o,
  output logic                  full_o,
  output logic [AWIDTH : 0]     usedw_o,
  output logic                  almost_empty_o,
  output logic                  almost_full_o
);

  localparam DEPTH = 1 << AWIDTH;

  logic [AWIDTH : 0] cnt;
  logic [AWIDTH - 1 : 0] wr_ptr, rd_ptr;
  logic wr_en, rd_en, valid;
  logic fifo_not_empty, need_data;
  logic last, pre_empty;

  always_ff @ (posedge clk_i)
    if (srst_i)
      fifo_not_empty <= '0;
    else if (cnt > AWIDTH'(1) || wr_en)
      fifo_not_empty <= '1;
    else if (pre_empty)
      fifo_not_empty <= '0;
    
  assign need_data = fifo_not_empty && !valid;

  always_ff @ (posedge clk_i)
    if (srst_i)
      valid <= '0;
    else if (pre_empty)
      valid <= '0;
    else if (fifo_not_empty)
      valid <= '1;

  assign last = valid && cnt == AWIDTH'(1);
  assign pre_empty = last && rdreq_i;

  assign wr_en = wrreq_i && !full_o;
  assign rd_en = rdreq_i && valid && !last || need_data;

  always_ff @ ( posedge clk_i )
    if ( srst_i )
      wr_ptr <= '0;
    else if ( wr_en )
      wr_ptr <= wr_ptr + 1'b1;

  always_ff @ ( posedge clk_i )
    if ( srst_i )
      rd_ptr <= '0;
    else if ( rd_en )
      rd_ptr <= rd_ptr + 1'b1;

  mixed_width_ram #(
      .WORDS ( DEPTH ),
      .RW    ( DWIDTH ),
      .WW    ( DWIDTH )
  ) memory (
      .clk   ( clk_i ),

      .we    ( wr_en ),
      .waddr ( wr_ptr ),
      .wdata ( data_i ),

      .re    ( rd_en ),
      .raddr ( rd_ptr ),
      .q     ( q_o )
  );

  always_ff @ (posedge clk_i)
    if ( srst_i )
      cnt <= '0;
    else if ( pre_empty )
      cnt <= wr_en;
    else if ( valid )
      case({wr_en, rd_en})
        2'b10: cnt <= cnt + AWIDTH'(1);
        2'b01: cnt <= cnt - AWIDTH'(1);
        default: cnt <= cnt;
      endcase
    else
      cnt <= cnt + wr_en;

  assign full_o = cnt == DEPTH;
  assign empty_o = !valid;
  assign usedw_o = cnt;
  assign almost_empty_o = (cnt < ALMOST_EMPTY_VALUE); 
  assign almost_full_o = (cnt >= ALMOST_FULL_VALUE);
endmodule