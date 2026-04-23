class ast_transaction  #(
    parameter int DATA_IN_W = 64,
    parameter int DATA_OUT_W = 256,
    parameter int EMPTY_IN_W = $clog2(DATA_IN_W/8),
    parameter int EMPTY_OUT_W = $clog2(DATA_OUT_W/8),
    parameter int MAX_SIZE = 65536,
    parameter int CHANNEL_W = 10
);
    localparam N = DATA_OUT_W / DATA_IN_W;
    logic [DATA_IN_W - 1 : 0] ast_data_i [];

    logic [MAX_SIZE - 1 : 0] size_i;
    logic [EMPTY_IN_W - 1 : 0] empty_i;

    logic [MAX_SIZE - 1 : 0] size_o;
    logic [EMPTY_OUT_W - 1 : 0] empty_o;

    logic [CHANNEL_W - 1 : 0] channel;
endclass