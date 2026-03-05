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
  logic wr_en, rd_en;

  assign wr_en = wrreq_i && !full_o;
  assign rd_en = rdreq_i && !empty_o;

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

  logic [DWIDTH - 1 : 0] data [0 : DEPTH - 1];
  always_ff @ (posedge clk_i)
    if ( wr_en )
      data[wr_ptr] <= data_i;

  logic [DWIDTH - 1 : 0] q_o1;
  generate
    if ( SHOWAHEAD )
        assign q_o1 = data[rd_ptr];
    else
      begin
        always_ff @ ( posedge clk_i )
          if ( srst_i )
            q_o1 <= '0;
          else if (rd_en)
            q_o1 <= data[rd_ptr];
      end
  endgenerate

  generate
    if ( REGISTER_OUTPUT )
      always_ff @ ( posedge clk_i )
        if ( srst_i )
          q_o <= '0;
        else
          q_o <= q_o1;
    else
      assign q_o = q_o1;
  endgenerate

  always_ff @ (posedge clk_i)
    if ( srst_i )
      cnt <= '0;
    else if ( wr_en && ~rd_en )
      cnt <= cnt + 1'b1;
    else if ( ~wr_en && rd_en )
      cnt <= cnt - 1'b1;

  assign full_o = cnt == DEPTH;
  assign empty_o = cnt == '0;
  assign usedw_o = cnt[AWIDTH-1:0];
  assign almost_empty_o = (cnt < ALMOST_EMPTY_VALUE);
  assign almost_full_o = (cnt >= ALMOST_FULL_VALUE);
endmodule