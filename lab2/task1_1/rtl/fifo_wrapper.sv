module fifo_wrapper #(
  parameter DWIDTH = 16,
  parameter AWIDTH = 6,
  parameter SHOWAHEAD = 1,
  parameter ALMOST_FULL_VALUE = 45,
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

  logic srst_i1;
  logic [DWIDTH - 1 : 0] data_i1;
  logic                  wrreq_i1;
  logic                  rdreq_i1;
  logic [DWIDTH - 1 : 0] q_o1;
  logic                  empty_o1;
  logic                  full_o1;
  logic                  almost_empty_o1;
  logic                  almost_full_o1;
  logic [AWIDTH : 0]     usedw_o1;

  always_ff @ ( posedge clk_i )
    begin
      srst_i1 <= srst_i;
      data_i1 <= data_i;
      wrreq_i1 <= wrreq_i;
      rdreq_i1 <= rdreq_i;

      q_o <= q_o1;
      empty_o <= empty_o1;
      full_o <= full_o1;
      usedw_o <= usedw_o1;
      almost_empty_o <= almost_empty_o1;
      almost_full_o <= almost_full_o1;
    end

  fifo #(
    .DWIDTH(DWIDTH),
    .AWIDTH(AWIDTH),
    .SHOWAHEAD(SHOWAHEAD),
    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
    .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
    .REGISTER_OUTPUT(REGISTER_OUTPUT)
  ) wrap (
    .clk_i (clk_i),
    .srst_i(srst_i1),
    .data_i(data_i1),
    .wrreq_i(wrreq_i1),
    .rdreq_i(rdreq_i1),
    .q_o(q_o1),
    .empty_o(empty_o1),
    .full_o(full_o1),
    .usedw_o(usedw_o1),
    .almost_empty_o(almost_empty_o1),
    .almost_full_o(almost_full_o1)
  );

endmodule