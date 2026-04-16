interface lifo_intf # (
    parameter int DWIDTH = 16,
    parameter int AWIDTH = 8
) (
    input logic clk_i,
    input logic srst_i
);
    logic [DWIDTH - 1 : 0] data_i;
    logic                  wrreq_i;
    logic                  rdreq_i;

    logic [DWIDTH - 1 : 0] q_o;
    logic                  empty_o;
    logic                  full_o;
    logic [AWIDTH : 0]     usedw_o;
    logic                  almost_full_o;
    logic                  almost_empty_o;
endinterface