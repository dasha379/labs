class ast_transaction  #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8
);
    logic [DATA_WIDTH - 1 : 0]    ast_data_i [$];

    logic [EMPTY_WIDTH - 1 : 0]   empty_i;

    logic [CHANNEL_WIDTH - 1 : 0] channel_i;
    int                           dir;
endclass