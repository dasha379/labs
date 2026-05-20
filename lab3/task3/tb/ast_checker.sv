class ast_checker #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);

    mailbox#(ast_transaction) drv2chk;
    mailbox#(ast_transaction) mon2chk;

    function new(mailbox#(ast_transaction) drv2chk, mailbox#(ast_transaction) mon2chk);
        this.drv2chk = drv2chk;
        this.mon2chk = mon2chk;
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
                    //$display("driver data = %d", word[i*8+:8]);
                end
            end
        return word;
    endfunction

    task automatic check(ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .DIR_WIDTH     (DIR_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) p, ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .DIR_WIDTH     (DIR_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) q);
        logic [DATA_WIDTH - 1 : 0] w1, w2;
        logic [DATA_WIDTH - 1 : 0] b1 [$];
        logic [DATA_WIDTH - 1 : 0] b2 [$];
        ast_transaction p_new = new(p.channel, p.dir);
        ast_transaction q_new = new(q.channel, q.dir);
        p_new.ast_data = p.ast_data;
        q_new.ast_data = q.ast_data;
        while (q_new.ast_data.size() > 0 && p_new.ast_data.size() > 0)
            begin
                w1 = get_word(p_new);
                w2 = get_word(q_new);
                b1.push_back(w1);
                b2.push_back(w2);
            end
        $display("checking....");
        if (p.dir !== q.dir) $error("mismathed packet types");
        
        if (b1 != b2)
            for (int i = 0; i < b1.size(); ++i)
                if (b1[i] != b2[i])
                    $error("wrong data: expected %0d, got %0d", b1[i], b2[i]);
        if (q.channel !== p.channel)
            $error("wrong channel signal: expected %d, got %d", p.channel, q.channel);
        if (q.ast_data.size() !== p.ast_data.size())
            $error("size of data is wrong: expected %d, got %d", p.ast_data.size(), q.ast_data.size());
    endtask

    task automatic run(int trans);
        int cnt;
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) p;
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .DIR_WIDTH     (DIR_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) q;
        
        forever
            begin
                // $display("%d", drv2chk.num());
                // $display("%d", mon2chk.num());
                drv2chk.get(p);
                mon2chk.get(q);
                check(p, q);
                cnt += 1;
                $display("TEST %d COMPLETED", cnt);

                if (cnt == trans) begin
                    $display("check finished");
                    break;
                end
            end
    endtask
endclass