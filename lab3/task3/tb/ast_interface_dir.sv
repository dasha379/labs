interface ast_interface_dir # (
    parameter int DIR_W
)(
    input logic clk,
    input logic rst
);

    logic [DIR_W - 1 : 0] dir_i;

endinterface