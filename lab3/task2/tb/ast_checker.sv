class ast_checker #(
    parameter int DATA_IN_W = 64,
    parameter int DATA_OUT_W = 256,
    parameter int EMPTY_IN_W = $clog2(DATA_IN_W/8),
    parameter int EMPTY_OUT_W = $clog2(DATA_OUT_W/8),
    parameter int CHANNEL_W = 10
);
    localparam int MAX_SIZE = 65536;
    localparam int N = DATA_OUT_W / DATA_IN_W;
    virtual ast_interface #(
        .DATA_IN_W(DATA_IN_W),
        .DATA_OUT_W(DATA_OUT_W),
        .EMPTY_IN_W(EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W(CHANNEL_W)
    ) intf;

    mailbox#(ast_transaction) gen2chk;

    function new(virtual ast_interface #(
        .DATA_IN_W(DATA_IN_W),
        .DATA_OUT_W(DATA_OUT_W),
        .EMPTY_IN_W(EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W(CHANNEL_W)
    ) intf, mailbox#(ast_transaction) gen2chk);
        this.gen2chk = gen2chk;
        this.intf = intf;
    endfunction

    function logic [DATA_OUT_W - 1 : 0] create_expected_data(ref logic [DATA_IN_W - 1 : 0] data_i [], int ind, logic [MAX_SIZE - 1 : 0] size_i);
        logic [DATA_OUT_W - 1 : 0] res = '0;

        for (int j = 0; j < N; ++j) begin
            int index = ind * N + j;
            if (index < size_i)
                res = res | (data_i[index] << (j * DATA_IN_W));
        end

        return res;
    endfunction

    task automatic run(int trans);
        check(trans);
    endtask

    task automatic check(int trans);
        ast_transaction #(
            .DATA_IN_W  (DATA_IN_W),
            .DATA_OUT_W (DATA_OUT_W),
            .EMPTY_IN_W (EMPTY_IN_W),
            .EMPTY_OUT_W(EMPTY_OUT_W),
            .MAX_SIZE   (MAX_SIZE),
            .CHANNEL_W  (CHANNEL_W)
        ) p;
        int start, end_;
        int done;
        logic [DATA_OUT_W - 1 : 0] exp_data;
        int i;
        done = 0;
        while(done < trans)
            begin
                gen2chk.get(p);
                while(1)
                    begin
                        @(posedge intf.clk_i);
                        if (intf.ast_valid_o && intf.ast_ready_i && intf.ast_startofpacket_o)
                            break;
                    end
                if (p.size_o > 0) begin
                    i = 0;
                    while (i < p.size_o)
                        begin
                            if (i > 0) begin
                                while (1) begin
                                    @ (posedge intf.clk_i);
                                    if (intf.ast_valid_o && intf.ast_ready_i) break;
                                end
                            end
                            start = (i == 0);
                            end_ = (i == p.size_o - 1);
                            exp_data = create_expected_data(p.ast_data_i, i, p.size_i);
                            if (exp_data != intf.ast_data_o)
                                $error("wrong data: expected - %b, got - %b", exp_data, intf.ast_data_o);
                            if (intf.ast_startofpacket_o != start)
                                $error("wrong start of packet: expected - %d, got - %d", start, intf.ast_startofpacket_o);
                            if (intf.ast_endofpacket_o != end_)
                                $error("wrong end of packet: expected - %d, got - %d", end_, intf.ast_endofpacket_o);
                            if (intf.ast_channel_o != p.channel)
                                $error("wrong channel signal: expected - %d, got - %d", p.channel, intf.ast_channel_o);
                            if (end_)
                                if (intf.ast_empty_o != p.empty_o)
                                    $error("wrong empty signal: expected - %d, got - %d", p.empty_o, intf.ast_empty_o);
                            @ (posedge intf.clk_i);

                            i += 1;
                            //end
                        end
                    $display("TEST COMPLETED");
                    done += 1;
            end
            else begin
                
                if (intf.ast_startofpacket_o != 1'b1)
                    $error("wrong start of packet: expected - %d, got - %d", 1'b1, intf.ast_startofpacket_o);
                if (intf.ast_endofpacket_o != 1'b1)
                    $error("wrong end of packet: expected - %d, got - %d", 1'b1, intf.ast_endofpacket_o);
                if (intf.ast_channel_o != p.channel)
                    $error("wrong channel signal: expected - %d, got - %d", p.channel, intf.ast_channel_o);
                if (intf.ast_empty_o != p.empty_o)
                    $error("wrong empty signal: expected - %d, got - %d", p.empty_o, intf.ast_empty_o);
                @ (posedge intf.clk_i);
                $display("TEST COMPLETED small");
                done += 1;
            end
            end
    endtask
endclass