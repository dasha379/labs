class ast_driver #(
    parameter int DATA_WIDTH = 64,
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8),
    parameter int CHANNEL_WIDTH = 8,
    parameter int TX_DIR = 4
);
    localparam int TX_DIR_W = $clog2(TX_DIR);

    mailbox#(ast_transaction) gen2drv;
    mailbox#(ast_transaction) drv2chk;
    
    virtual ast_interface_dir #(.DIR_W(TX_DIR_W)) dir_intf;

    virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf;

    function new(virtual ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf, virtual ast_interface_dir #(.DIR_W(TX_DIR_W)) dir_intf, mailbox#(ast_transaction) gen2drv, mailbox#(ast_transaction) drv2chk);
        this.gen2drv  = gen2drv;
        this.drv2chk  = drv2chk;
        this.intf     = intf;
        this.dir_intf = dir_intf;
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

    task automatic drive(int st, int e, logic [DATA_WIDTH - 1 : 0] data, logic [CHANNEL_WIDTH - 1 : 0] ch, logic [EMPTY_WIDTH - 1 : 0] empty, bit val, logic [TX_DIR_W - 1 : 0] dir);
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
            .EMPTY_WIDTH   (EMPTY_WIDTH),
            .CHANNEL_WIDTH (CHANNEL_WIDTH)
        ) p;
        reset();
        repeat(num_trans)
            begin
                int i = 0;
                gen2drv.get(p);
                drv2chk.put(p);
                if (p.ast_data_i.size() > 0) begin
                    while (i < p.ast_data_i.size())
                        begin
                            if ($urandom_range(1, 100) <= prob)
                                begin
                                    while (!intf.in_cb.ast_ready) @ (intf.in_cb);
                                    drive((i == 0), i == (p.ast_data_i.size() - 1), p.ast_data_i[i], p.channel_i, p.empty_i, '1, p.dir);
                                    $display("signals sent, data = %d, channel = %d", p.ast_data_i[i], p.channel_i);
                                end
                            else
                                begin
                                    drive($urandom_range(1), $urandom_range(1), DATA_WIDTH'($urandom()), CHANNEL_WIDTH'($urandom()), EMPTY_WIDTH'($urandom()), '0, TX_DIR_W'($urandom()));
                                end
                            i += 1;
                            @ (intf.in_cb);
                        end
                end
                else begin
                    while (!intf.in_cb.ast_ready) @ (intf.in_cb);
                    drive('1, '1, 'x, p.channel_i, p.empty_i, '1, p.dir);
                    @ (intf.in_cb);
                end
                
                @ (intf.in_cb);
            end
    endtask
endclass