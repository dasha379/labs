class ast_monitor #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int DIR_WIDTH = $clog2(TX_DIR);

    typedef ast_transaction # (.DATA_WIDTH(DATA_WIDTH), .CHANNEL_WIDTH(CHANNEL_WIDTH), .DIR_WIDTH(DIR_WIDTH)) tr;
    
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
                int j = i;
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
        forever begin
            tr p;
            logic [7 : 0] buffer [$];
            logic [CHANNEL_WIDTH - 1 : 0] ch = 0;
            int cnt = 0;
            while (!(vif.out_cb.ast_valid && vif.ast_ready))
                begin
                    @(vif.out_cb);
                end

            if (vif.out_cb.ast_startofpacket)
                begin
                    assert(buffer.size()==0) else buffer.delete();
                    ch = vif.out_cb.ast_channel;
                end
            else while (!vif.out_cb.ast_startofpacket) @(vif.out_cb);
            
            while (!vif.out_cb.ast_endofpacket) begin
                for (int i = 0; i < DATA_WIDTH/8; ++i)
                    buffer.push_back(vif.out_cb.ast_data[i*8 +: 8]);
                @(vif.out_cb);
            end
            
            if (vif.out_cb.ast_endofpacket)
                begin
                    for (int i = 0; i < DATA_WIDTH/8; ++i)
                        buffer.push_back(vif.out_cb.ast_data[i*8 +: 8]);
                    p = new(ch, dir);
                    p.ast_data = buffer;
                    p.channel = ch;
                    p.dir = dir;
                    
                    $display("monitor received: channel = %d, dir = %d", ch, dir);
                    //for (int i = 0; i < buffer.size();++i) $display("data = %d", buffer[i]);
                    mon2chk.put(p.copy());
                    buffer.delete();
                end
            @ (vif.out_cb);
        end
    endtask
endclass