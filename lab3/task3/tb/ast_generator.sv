class ast_generator #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int TX_DIR_W = $clog2(TX_DIR);

    mailbox#(ast_transaction) gen2drv;
    
    function new(mailbox#(ast_transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task automatic run(int size, int dir_val);
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .EMPTY_WIDTH   (EMPTY_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) p;
        int words = size / (DATA_WIDTH / 8);
        p = new();

        if (words == 0 && size > 0)
            p.empty_i = DATA_WIDTH / 8 - 1;
        else
            p.empty_i = size % (DATA_WIDTH / 8);

        p.channel_i = CHANNEL_WIDTH'($urandom());
        p.dir = dir_val;

        if (words > 0)
            for (int i = 0; i < words; ++i)
                p.ast_data_i.push_back(DATA_WIDTH'($urandom()));
        gen2drv.put(p);
    endtask

endclass