class ast_driver #(
    parameter int DATA_IN_W = 64,
    parameter int DATA_OUT_W = 256,
    parameter int EMPTY_IN_W = $clog2(DATA_IN_W/8),
    parameter int EMPTY_OUT_W = $clog2(DATA_OUT_W/8),
    parameter int CHANNEL_W = 10
);
    localparam int MAX_SIZE = 65536;
    mailbox#(ast_transaction) gen2drv;
    mailbox#(ast_transaction) gen2chk;
    
    virtual ast_interface #(
        .DATA_IN_W(DATA_IN_W),
        .DATA_OUT_W(DATA_OUT_W),
        .EMPTY_IN_W(EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W(CHANNEL_W)
    ) intf;

    function new(virtual ast_interface #(
        .DATA_IN_W(DATA_IN_W),
        .DATA_OUT_W(DATA_OUT_W),
        .EMPTY_IN_W(EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W(CHANNEL_W)
    ) intf, mailbox#(ast_transaction) gen2drv, mailbox#(ast_transaction) gen2chk);
        this.gen2drv = gen2drv;
        this.gen2chk = gen2chk;
        this.intf = intf;
    endfunction

    task automatic reset();
        intf.ast_data_i          <= '0;
        intf.ast_startofpacket_i <= '0;
        intf.ast_endofpacket_i   <= '0;
        intf.ast_valid_i         <= '0;
        intf.ast_empty_i         <= '0;
        intf.ast_channel_i       <= '0;
    endtask

    task automatic run(int prob, int num_trans);
        ast_transaction #(
            .DATA_IN_W  (DATA_IN_W),
            .DATA_OUT_W (DATA_OUT_W),
            .EMPTY_IN_W (EMPTY_IN_W),
            .EMPTY_OUT_W(EMPTY_OUT_W),
            .MAX_SIZE   (MAX_SIZE),
            .CHANNEL_W  (CHANNEL_W)
        ) p;
        repeat (num_trans)
            begin
                int i = 0;
                gen2drv.get(p);
                gen2chk.put(p);
                if (p.size_i > 0) begin
                    while (i < p.size_i)
                        begin
                            if ($urandom_range(1, 100) <= prob)
                                begin
                                    wait(intf.ast_ready_o);
                                    intf.ast_data_i          <= p.ast_data_i[i];
                                    intf.ast_startofpacket_i <= (i == 0);
                                    intf.ast_endofpacket_i   <= (i == (p.size_i - 1));
                                    intf.ast_valid_i         <= '1;
                                    // сигнал empty генерируется только в момент endofpacket
                                    intf.ast_empty_i         <= (i == (p.size_i - 1)) ? p.empty_i : 'x;
                                    // генерируем channel в начале пакета для всего пакета
                                    intf.ast_channel_i       <= (i == 0) ? p.channel : 'x;
                                    intf.ast_ready_i         <= '1;
                                end
                            else
                                begin
                                    intf.ast_data_i          <= DATA_IN_W'($urandom());
                                    intf.ast_startofpacket_i <= $urandom_range(1);
                                    intf.ast_endofpacket_i   <= $urandom_range(1);
                                    intf.ast_valid_i         <= '0;
                                    intf.ast_empty_i         <= EMPTY_IN_W'($urandom());
                                    intf.ast_channel_i       <= CHANNEL_W'($urandom());
                                    intf.ast_ready_i         <= '1;
                                end
                            @(posedge intf.clk_i);
                            i += 1;
                        end
                end
                else begin
                    wait(intf.ast_ready_o);
                    intf.ast_data_i          <= 'x;
                    intf.ast_startofpacket_i <= 1'b1;
                    intf.ast_endofpacket_i   <= 1'b1;
                    intf.ast_valid_i         <= '1;
                    // сигнал empty генерируется только в момент endofpacket
                    intf.ast_empty_i         <= p.empty_i;
                    // генерируем channel в начале пакета для всего пакета
                    intf.ast_channel_i       <= p.channel;
                    intf.ast_ready_i         <= '1;
                    @(posedge intf.clk_i);
                end
                
                @ (posedge intf.clk_i);
                reset();
            end
    endtask
endclass