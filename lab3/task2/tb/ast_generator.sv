class ast_generator #(
    parameter int DATA_IN_W = 64,
    parameter int DATA_OUT_W = 256,
    parameter int EMPTY_IN_W = $clog2(DATA_IN_W/8),
    parameter int EMPTY_OUT_W = $clog2(DATA_OUT_W/8),
    parameter int CHANNEL_W = 10
);
    localparam int MAX_SIZE = 65536;
    localparam int N = DATA_OUT_W / DATA_IN_W;
    mailbox#(ast_transaction) gen2drv;
    mailbox#(ast_transaction) gen2chk;
    
    function new(mailbox#(ast_transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task automatic run(int small_1, int small_2, int max, int random, int empty_en, int empty_dis);
        // small packets
        repeat (small_1) generating($urandom_range(1, DATA_OUT_W / 8));
        repeat (small_2) generating($urandom_range(1, DATA_IN_W / 8));
        // max length
        repeat (max) generating(MAX_SIZE);
        // random
        repeat (random) generating($urandom_range(DATA_OUT_W / 8, MAX_SIZE - 1));
        // no empty
        repeat (empty_dis) generating($urandom_range(1, 10)*DATA_OUT_W / 8);
        // empty
        repeat (empty_en) generating($urandom_range(1, 10)*DATA_OUT_W / 8 + $urandom_range(1, 10));
    endtask

    task automatic generating(int val);
        ast_transaction #(
            .DATA_IN_W  (DATA_IN_W),
            .DATA_OUT_W (DATA_OUT_W),
            .EMPTY_IN_W (EMPTY_IN_W),
            .EMPTY_OUT_W(EMPTY_OUT_W),
            .MAX_SIZE   (MAX_SIZE),
            .CHANNEL_W  (CHANNEL_W)
        ) p;
        int tmp;
        p = new();
        tmp = val;
        p.size_i = tmp / (DATA_IN_W / 8);

        if (p.size_i == 0 && tmp > 0)
            p.empty_i = DATA_IN_W / 8 - 1;
        else
            p.empty_i = tmp % (DATA_IN_W / 8);

        p.size_o = tmp / (DATA_OUT_W / 8);

        if (p.size_o == 0 && tmp > 0)
            p.empty_o = DATA_OUT_W / 8 - 1;
        else
            p.empty_o = tmp % (DATA_OUT_W / 8);

        p.channel = CHANNEL_W'($urandom());

        p.ast_data_i = new[p.size_i];
        if (p.size_i > 0)
            for (int i = 0; i < p.size_i; ++i)
                p.ast_data_i[i] = DATA_IN_W'($urandom());
        gen2drv.put(p);
    endtask

endclass