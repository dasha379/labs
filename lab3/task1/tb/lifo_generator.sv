class lifo_generator # (
    parameter int DWIDTH = 16,
    parameter int AWIDTH = 8
);
    mailbox#(lifo_transaction) gen2mon;

    virtual lifo_intf #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH)) intf;

    function new(virtual lifo_intf #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH)) intf, mailbox#(lifo_transaction) gen2mon);
        this.intf = intf;
        this.gen2mon = gen2mon;
    endfunction

    task automatic reset();
        intf.data_i  = 'x;
        intf.wrreq_i = '0;
        intf.rdreq_i = '0;
    endtask

    task automatic send_data(
        input int num_tests,
        input int w,
        input int r
    );
        repeat(num_tests)
            begin
                
                lifo_transaction p;
                p = new();
                reset();
                if (!intf.full_o && $urandom_range(1, 100) <= w)
                    begin
                        intf.wrreq_i <= '1;
                        intf.data_i  <= DWIDTH'($urandom());
                    end
                if (!intf.empty_o && $urandom_range(1, 100) <= r)
                    intf.rdreq_i <= '1;
                @(posedge intf.clk_i);
                p.wr = intf.wrreq_i;
                p.rd = intf.rdreq_i;
                p.data = intf.data_i;
                gen2mon.put(p);
            end
    endtask
endclass