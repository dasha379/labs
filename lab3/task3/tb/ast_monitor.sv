class ast_monitor #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
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
            virtual ast_interface #(
                .DATA_WIDTH    (DATA_WIDTH),
                .EMPTY_WIDTH   (EMPTY_WIDTH),
                .CHANNEL_WIDTH (CHANNEL_WIDTH)
            )   vif = intf[i];
            fork
                monitor(trans, i, vif);
                set_ready(vif);
            join_any
        end
    endtask

    task automatic set_ready(virtual ast_interface vif);
        forever begin
            @ (vif.out_cb);
            vif.out_cb.ast_ready <= '1;
        end
    endtask

    task automatic monitor(int trans, int dir, virtual ast_interface vif);
        ast_transaction p;
        logic [CHANNEL_WIDTH - 1 : 0] ch;
        logic [DATA_WIDTH - 1 : 0] d [$];
        
        repeat(trans) begin
            if (!vif.out_cb.ast_valid || !vif.ast_ready) @ (vif.out_cb);

            if (vif.out_cb.ast_startofpacket)
                begin
                    ch = vif.out_cb.ast_channel;
                    assert(d.size() == 0) else d.delete();
                end

            d.push_back(vif.out_cb.ast_data);
            
            @(vif.out_cb);
            
            while (!vif.out_cb.ast_endofpacket) begin
                d.push_back(vif.out_cb.ast_data);
                @(vif.out_cb);
            end
            

            d.push_back(vif.out_cb.ast_data);
            
            p = new();
            p.channel_i = ch;
            p.ast_data_i = d;
            p.empty_i = vif.out_cb.ast_empty;
            p.dir = dir;
            
            $display("MONITOR[%0d]: PACKET CAPTURED - words=%0d, empty=%0d, channel=%0d, data=%0d",
                     dir, p.ast_data_i.size(), p.empty_i, p.channel_i, p.ast_data_i[$]);
            
            mon2chk.put(p);
            @ (vif.out_cb);
        end
    endtask
endclass