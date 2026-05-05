interface ast_interface #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8
) (
    input logic clk_i,
    input logic srst_i
);
    logic [DATA_WIDTH    - 1 : 0] ast_data;
    logic                         ast_startofpacket;
    logic                         ast_endofpacket;
    logic                         ast_valid;
    logic [EMPTY_WIDTH   - 1 : 0] ast_empty;
    logic [CHANNEL_WIDTH - 1 : 0] ast_channel;
    logic                         ast_ready = '1;

    clocking in_cb @ (posedge clk_i);
        output ast_data;
        output ast_startofpacket;
        output ast_endofpacket;
        output ast_valid;
        output ast_empty;
        output ast_channel;
        input  ast_ready;
    endclocking

    clocking out_cb @ (posedge clk_i);
        input  ast_data;
        input  ast_startofpacket;
        input  ast_endofpacket;
        input  ast_valid;
        input  ast_empty;
        input  ast_channel;
        output ast_ready;
    endclocking

endinterface