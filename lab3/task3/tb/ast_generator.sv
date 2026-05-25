class ast_generator #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);
    localparam int MAX_SIZE = 65536;

    typedef ast_transaction # (.DATA_WIDTH(DATA_WIDTH), .CHANNEL_WIDTH(CHANNEL_WIDTH), .DIR_WIDTH(DIR_WIDTH)) tr;

    mailbox#(ast_transaction) gen2drv;
    
    function new(mailbox#(ast_transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task automatic no_empty();
        tr p;
        for (int i = 0; i < TX_DIR; ++i)
            begin
                int size = $urandom_range(1, 10) * DATA_WIDTH / 8;
                p = new(.dir(i));
                p.gen_data(size);
                gen2drv.put(p);
            end
    endtask

    task automatic with_empty();
        tr p;
        for (int i = 0; i < TX_DIR; ++i)
            begin
                int empty = $urandom_range(1, DATA_WIDTH / 8 - 1);
                int size = $urandom_range(1, 10) * DATA_WIDTH / 8 + empty;
                p = new(.dir(i));
                p.gen_data(size);
                gen2drv.put(p);
            end
    endtask

    task automatic random_p();
        tr p;
        for (int i = 0; i < TX_DIR; ++i)
            begin
                int size = $urandom_range(1, MAX_SIZE - 1);
                int empty = size % (DATA_WIDTH / 8);
                p = new(.dir(i));
                p.gen_data(size);
                gen2drv.put(p);
            end
    endtask

    task automatic max_p();
        tr p;
        int d = 2;
        int size = MAX_SIZE;
        p = new(.dir(d));
        p.gen_data(size);
        gen2drv.put(p);
    endtask

    task automatic one_p_data_width();
        tr p;
        for (int i = 0; i < TX_DIR; ++i)
            begin
                int size = DATA_WIDTH / 8;
                p = new(.dir(i));
                p.gen_data(size);
                gen2drv.put(p);
            end
    endtask

    task automatic one_p_one_byte();
        tr p;
        //logic [DIR_WIDTH - 1 : 0] d = DIR_WIDTH'($urandom());
        logic [DIR_WIDTH - 1 : 0] d = 1;
        int size = 1;
        int empty = size;
        p = new(.dir(d));
        p.gen_data(size);
        gen2drv.put(p);
    endtask

endclass