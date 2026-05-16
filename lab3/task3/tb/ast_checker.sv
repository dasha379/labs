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

    task automatic check(ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .DIR_WIDTH     (DIR_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) p, ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .DIR_WIDTH     (DIR_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) q);
        $display("checking....");
        if (p.dir != q.dir) $error("mismathed packet types");
        if (q.ast_data !== p.ast_data)
            $error("wrong data: expected %b, got %b", p.ast_data, q.ast_data);
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
                drv2chk.peek(p);
                mon2chk.peek(q);
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