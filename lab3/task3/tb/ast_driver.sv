class ast_driver #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);

    mailbox#(ast_transaction) gen2drv;
    mailbox#(ast_transaction) drv2chk;
    
    virtual ast_interface_dir #(.DIR_W(DIR_WIDTH)) dir_intf;

    virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf;

    function new(virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf, virtual ast_interface_dir #(.DIR_W(DIR_WIDTH)) dir_intf, mailbox#(ast_transaction) gen2drv, mailbox#(ast_transaction) drv2chk);
        this.gen2drv  = gen2drv;
        this.drv2chk  = drv2chk;
        this.intf     = intf;
        this.dir_intf = dir_intf;
    endfunction

    function automatic logic [EMPTY_WIDTH - 1 : 0] get_empty(ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH)
        ) p);
        int size = p.ast_data.size();
        logic [EMPTY_WIDTH - 1 : 0] empty = size % (DATA_WIDTH / 8);
        return empty;
    endfunction

    function automatic logic [DATA_WIDTH - 1 : 0] get_word(ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH)
        ) p);
        logic [DATA_WIDTH - 1 : 0] word;

        for (int i = 0; i < DATA_WIDTH / 8; ++i)
            begin
                if (p.ast_data.size() > 0) begin
                    word[i*8 +: 8] = p.ast_data.pop_front();
                    //$display(word[i*8+:8]);
                end
            end
        return word;
    endfunction

    task automatic reset();
        intf.in_cb.ast_data          <= '0;
        intf.in_cb.ast_startofpacket <= '0;
        intf.in_cb.ast_endofpacket   <= '0;
        intf.in_cb.ast_valid         <= '0;
        intf.in_cb.ast_empty         <= '0;
        intf.in_cb.ast_channel       <= '0;
        dir_intf.dir_i               <= '0;
    endtask

    task automatic drive(int st, int e, logic [DATA_WIDTH - 1 : 0] data, logic [CHANNEL_WIDTH - 1 : 0] ch, logic [EMPTY_WIDTH - 1 : 0] empty, bit val, logic [DIR_WIDTH - 1 : 0] dir);
        intf.in_cb.ast_data          <= data;
        intf.in_cb.ast_startofpacket <= st;
        intf.in_cb.ast_endofpacket   <= e;
        intf.in_cb.ast_valid         <= val;
        // сигнал empty генерируется только в момент endofpacket
        intf.in_cb.ast_empty         <= e ? empty : 'x;
        // генерируем channel в начале пакета для всего пакета
        intf.in_cb.ast_channel       <= st ? ch : 'x;
        dir_intf.dir_i               <= st ? dir : 'x;
    endtask

    task automatic run(int prob, int num_trans);
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH)
        ) p;
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH)
        ) p_new;
        logic [DATA_WIDTH - 1 : 0] w;
        logic [EMPTY_WIDTH - 1 : 0] empty;
        int size = 0;
        reset();
        repeat(num_trans)
            begin
                int i = 0;
                gen2drv.get(p);
                p_new = new();
                p_new.ast_data = p.ast_data;
                p_new.channel = p.channel;
                p_new.dir = p.dir;
                drv2chk.put(p_new);

                size = p.ast_data.size();

                do
                    begin
                        if ($urandom_range(1, 100) <= prob)
                            begin
                                
                                while (!intf.in_cb.ast_ready) @(intf.in_cb);
                                $display("i=%d", i);
                                //size = p.ast_data.size();
                                w = get_word(p);
                                empty = get_empty(p);
                                drive((i == 0), (p.ast_data.size()==0), w, p.channel, empty, '1, p.dir);
                                $display("signals sent, data = %d, channel = %d", w, p.channel);
                            end
                        else
                            begin
                                drive($urandom_range(1), $urandom_range(1), DATA_WIDTH'($urandom()), CHANNEL_WIDTH'($urandom()), EMPTY_WIDTH'($urandom()), '0, DIR_WIDTH'($urandom()));
                            end
                        i += 1;
                        @ (intf.in_cb);
                    end while (p.ast_data.size() > 0);
                
                @ (intf.in_cb);
            end
    endtask
endclass