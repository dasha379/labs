module sorting_wr #(
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

  logic                  Wsrst_i;
  logic [DWIDTH - 1 : 0] Wsnk_data_i;
  logic                  Wsnk_startofpacket_i;
  logic                  Wsnk_endofpacket_i;
  logic                  Wsnk_valid_i;

  logic                  Wsnk_ready_o;
  logic [DWIDTH - 1 : 0] Wsrc_data_o;
  logic                  Wsrc_startofpacket_o;
  logic                  Wsrc_endofpacket_o;
  logic                  Wsrc_valid_o;
  logic                  Wsrc_ready_i;

  always_ff @ (posedge clk_i)
    begin
      Wsrst_i              <= srst_i;
      Wsnk_data_i          <= snk_data_i;
      Wsnk_startofpacket_i <= snk_startofpacket_i;
      Wsnk_endofpacket_i   <= snk_endofpacket_i;
      Wsnk_valid_i         <= snk_valid_i;
      Wsrc_ready_i         <= src_ready_i;

      snk_ready_o          <= Wsnk_ready_o;
      src_data_o           <= Wsrc_data_o;
      src_startofpacket_o  <= Wsrc_startofpacket_o;
      src_endofpacket_o    <= Wsrc_endofpacket_o;
      src_valid_o          <= Wsrc_valid_o;
    end

  sorting #(
    .DWIDTH     (DWIDTH),
    .MAX_PKT_LEN(MAX_PKT_LEN)
  ) wrap (
    .clk_i              (clk_i),
    .srst_i             (Wsrst_i),
    .snk_data_i         (Wsnk_data_i),
    .snk_startofpacket_i(Wsnk_startofpacket_i),
    .snk_endofpacket_i  (Wsnk_endofpacket_i),
    .snk_valid_i        (Wsnk_valid_i),

    .snk_ready_o        (Wsnk_ready_o),
    .src_data_o         (Wsrc_data_o),
    .src_startofpacket_o(Wsrc_startofpacket_o),
    .src_endofpacket_o  (Wsrc_endofpacket_o),
    .src_valid_o        (Wsrc_valid_o),

    .src_ready_i        (Wsrc_ready_i)
  );
endmodule