class ast_checker #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int TX_DIR_W = $clog2(TX_DIR);

    mailbox#(ast_transaction) drv2chk;
    mailbox#(ast_transaction) mon2chk;

    function new(mailbox#(ast_transaction) drv2chk, mailbox#(ast_transaction) mon2chk);
        this.drv2chk = drv2chk;
        this.mon2chk = mon2chk;
    endfunction

    task automatic check(ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) p, ast_transaction #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) q);
        if (q.dir === p.dir)
            begin
                $display("checking....");
                if (q.ast_data_i !== p.ast_data_i)
                    $error("wrong data: expected - %b, got - %b", p.ast_data_i, q.ast_data_i);
                if (q.channel_i !== p.channel_i)
                    $error("wrong channel signal: expected - %d, got - %d", p.channel_i, q.channel_i);
                if (q.empty_i !== p.empty_i)
                    $error("wrong empty signal: expected - %d, got - %d", p.empty_i, q.empty_i);
            end
    endtask

    task automatic run(int trans);
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .EMPTY_WIDTH   (EMPTY_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) p;
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .EMPTY_WIDTH   (EMPTY_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) q;
        forever
            begin
                drv2chk.get(p);
                mon2chk.get(q);
                check(p, q);
            end
    endtask
endclass