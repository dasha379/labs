class ast_transaction  #(
    parameter int DATA_WIDTH = 64,
    parameter int CHANNEL_WIDTH = 8,
    parameter int DIR_WIDTH = 2
);
    logic [7 : 0]    ast_data [$];
    logic [CHANNEL_WIDTH - 1 : 0] channel;
    logic [DIR_WIDTH - 1 : 0]     dir;

    function new(
        logic [CHANNEL_WIDTH - 1 : 0] channel = $urandom_range(0, 2**CHANNEL_WIDTH - 1),
        logic [DIR_WIDTH - 1 : 0] dir = $urandom_range(0, 2**DIR_WIDTH - 1)
    );
        this.channel = channel;
        this.dir = dir;
    endfunction

    function void gen_data(int size);
        for (int i = 0; i < size; ++i)
            ast_data.push_back($urandom_range(0, 255));
    endfunction

    function ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) copy();
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) c = new(this.channel, this.dir);
        for (int i = 0; i < this.ast_data.size(); i++)
            c.ast_data.push_back(this.ast_data[i]);
        return c;
    endfunction
endclass