class lifo_monitor #(
    parameter int DWIDTH = 16,
    parameter int AWIDTH = 8,
    parameter int ALMOST_FULL_VALUE = 2,
    parameter int ALMOST_EMPTY_VALUE = 2
);
    mailbox#(lifo_transaction) gen2mon;

    localparam int size = 1 << AWIDTH;
    logic [DWIDTH - 1 : 0] stack [$:size - 1];
    logic [DWIDTH - 1 : 0] cur_el;
    virtual lifo_intf #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH)) intf;

    function new(virtual lifo_intf #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH)) intf, mailbox#(lifo_transaction) gen2mon);
        this.intf = intf;
        this.gen2mon = gen2mon;
    endfunction

    task automatic stack_fill();
        lifo_transaction p;
        forever
            begin
                gen2mon.get(p);
                @(posedge intf.clk_i);
                if (p.rd && stack.size() > 0)
                    cur_el = stack.pop_front();
                if (p.wr && stack.size() < size)
                    stack.push_front(p.data);
                
                check();
            end
    endtask

    task automatic run();
        stack_fill();
    endtask

    function void reset();
        stack.delete();
    endfunction

    task automatic check();
            
        if (intf.empty_o != (stack.size() == 0))
            $error("empty signal expected: %d, got: %d", stack.size() == 0, intf.empty_o);
        if (intf.full_o != (stack.size() == size))
            $error("full signal expected: %d, got: %d", stack.size() == size, intf.full_o);
        if (intf.almost_empty_o != (stack.size() <= ALMOST_EMPTY_VALUE))
            $error("almost empty signal expected: %d, got: %d", stack.size() <= ALMOST_EMPTY_VALUE, intf.almost_empty_o);
        if (intf.almost_full_o != (stack.size() >= ALMOST_FULL_VALUE))
            $error("almost full signal expected: %d, got: %d", stack.size() >= ALMOST_FULL_VALUE, intf.almost_full_o);
        if (intf.usedw_o != stack.size())
            $error("amount of words in the lifo expected: %d, got: %d", stack.size(), intf.usedw_o);

        if (intf.q_o != cur_el)
            $error("expected element: %d, got: %d", cur_el, intf.q_o);
    endtask

endclass