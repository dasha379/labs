class ast_checker #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);
    localparam int BYTES_PER_WORD = DATA_WIDTH / 8;

    typedef ast_transaction # (.DATA_WIDTH(DATA_WIDTH), .CHANNEL_WIDTH(CHANNEL_WIDTH), .DIR_WIDTH(DIR_WIDTH)) tr;

    mailbox#(ast_transaction) drv2chk;
    mailbox#(ast_transaction) mon2chk;

    function new(mailbox#(ast_transaction) drv2chk, mailbox#(ast_transaction) mon2chk);
        this.drv2chk = drv2chk;
        this.mon2chk = mon2chk;
    endfunction

    function automatic logic [DATA_WIDTH - 1 : 0] get_word(ref tr p);
        logic [DATA_WIDTH - 1 : 0] word;
        for (int i = 0; i < BYTES_PER_WORD; ++i) begin
            if (p.ast_data.size() > 0) begin
                word[i*8 +: 8] = p.ast_data.pop_front();
            end
        end
        return word;
    endfunction

    task automatic check(ref tr p, ref tr q);
        logic [DATA_WIDTH - 1 : 0] w1, w2;
        logic [DATA_WIDTH - 1 : 0] b1[$];
        logic [DATA_WIDTH - 1 : 0] b2[$];
        
        tr p_new = p.copy();
        tr q_new = q.copy();
        
        $display("checking....");
        
        while (p_new.ast_data.size() > 0 && q_new.ast_data.size() > 0) begin
            w1 = get_word(p_new);
            w2 = get_word(q_new);
            b1.push_back(w1);
            b2.push_back(w2);
        end

        if (p.dir !== q.dir) $error("data direction is wrong: expected %0d, got %0d", p.dir, q.dir);
        
        if (b1.size() !== b2.size()) begin
            $error("wrong size: expected %0d words, got %0d words", b1.size(), b2.size());
        end else begin
            for (int i = 0; i < b1.size(); i++) begin
                if (b1[i] !== b2[i]) begin
                    $error("wrong word %0d: expected %0d, got %0d", i, b1[i], b2[i]);
                end
                else $display("word %0d = %0d", i, b1[i]);
            end
        end
        
        if (q.channel !== p.channel) begin
            $error("wrong channel signal: expected %0d, got %0d", p.channel, q.channel);
        end
        
        if (q.ast_data.size() !== p.ast_data.size()) begin
            $error("size of data is wrong: expected %0d bytes, got %0d bytes", 
                p.ast_data.size(), q.ast_data.size());
        end
    endtask

    task run(int trans);
        int cnt = 0;
        
        while (cnt < trans) begin
            tr p;
            tr q;
            drv2chk.get(p);
            mon2chk.get(q);
            check(p, q);
            cnt += 1;
            $display("TEST %0d COMPLETED", cnt);
        end
        
        $display("check finished");
    endtask
endclass