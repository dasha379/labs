class ast_monitor #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);
    virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf [TX_DIR - 1 : 0];

    mailbox#(ast_transaction) mon2chk;

    function new (virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf [TX_DIR - 1 : 0], mailbox#(ast_transaction) mon2chk);
        this.intf = intf;
        this.mon2chk = mon2chk;
    endfunction

    task automatic run(int trans);
        for (int i = 0; i < TX_DIR; ++i) begin
            fork
                automatic int j = i;
                monitor(trans, j, intf[j]);
                set_ready(intf[j]);
            join_none
        end
        
    endtask

    task automatic set_ready(virtual ast_interface vif);
        forever begin
            @ (vif.out_cb);
            vif.out_cb.ast_ready <= '1;
        end
    endtask

    task automatic monitor(int trans, int dir, virtual ast_interface vif);
        ast_transaction #(
            .DATA_WIDTH    (DATA_WIDTH),
            .DIR_WIDTH   (DIR_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) p;

        logic [7 : 0] buffer [$];
        logic [CHANNEL_WIDTH - 1 : 0] ch;
        int cnt = 0;

        forever begin
            while (!(vif.out_cb.ast_valid && vif.ast_ready))
                begin
                    @(vif.out_cb);
                end

            if (vif.out_cb.ast_startofpacket)
                begin
                    buffer.delete();
                    ch = vif.out_cb.ast_channel;
                end

            for (int i = 0; i < DATA_WIDTH/8; ++i)
                buffer.push_back(vif.out_cb.ast_data[i*8 +: 8]);
            
            if (vif.out_cb.ast_endofpacket)
                begin
                    p = new(ch, dir);
                    p.ast_data = buffer;
                    p.channel = ch;
                    p.dir = dir;
                    
                    $display("monitor received: channel = %d, dir = %d, data = %d", ch, dir, buffer[$]);
                    mon2chk.put(p);
                end

            @ (vif.out_cb);
        end
    endtask
endclass