`timescale 1ns/1ps

module lifo_tb;
    import test_pkg::*;
    parameter int  DWIDTH = 16;
    parameter int  AWIDTH = 8;
    parameter int  ALMOST_FULL_VALUE = 2;
    parameter int  ALMOST_EMPTY_VALUE = 2;
    localparam int WORDS = 1 << AWIDTH;

    logic clk_i;
    logic srst_i;

    lifo_intf # (
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) intf (
        .clk_i(clk_i),
        .srst_i(srst_i)
    );

    mailbox#(lifo_transaction) gen2mon = new();

    lifo_generator # (
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) gen = new(intf, gen2mon);

    lifo_monitor # (
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE)
    ) mon = new(intf, gen2mon);

    initial
        begin
            clk_i = '0;
            forever #5 clk_i = ~clk_i;
        end
    
    lifo # (
        .DWIDTH      (DWIDTH),
        .AWIDTH      (AWIDTH),
        .ALMOST_EMPTY(ALMOST_EMPTY_VALUE),
        .ALMOST_FULL (ALMOST_FULL_VALUE)
    ) DUT (
        .clk_i         (clk_i),
        .srst_i        (srst_i),

        .data_i        (intf.data_i),
        .wrreq_i       (intf.wrreq_i),
        .rdreq_i       (intf.rdreq_i),

        .q_o           (intf.q_o),
        .empty_o       (intf.empty_o),
        .full_o        (intf.full_o),
        .almost_empty_o(intf.almost_empty_o),
        .almost_full_o (intf.almost_full_o),
        .usedw_o       (intf.usedw_o)
    );

    task reset();
        srst_i <= '1;
        mon.reset();
        repeat (2) @ (posedge clk_i);
        srst_i <= '0;
    endtask

    task automatic test_write();
        fork
            gen.send_data(WORDS, 100, 0);
            mon.run();
        join_any
        $display("full_write test complete.");
    endtask

    task automatic test_write_more();
        fork
            gen.send_data(WORDS + 50, 100, 0);
            mon.run();
        join_any
        $display("full_write_more test complete.");
    endtask

    task automatic test_read();
        fork
            gen.send_data(WORDS, 0, 100);
            mon.run();
        join_any
        $display("full_read test complete.");
    endtask

    task automatic test_read_more();
        fork
            gen.send_data(WORDS + 50, 0, 100);
            mon.run();
        join_any
        $display("full_read_more test complete.");
    endtask

    task automatic test_write_read();
        fork
            begin
                gen.send_data(500, 70, 30);
                gen.send_data(500, 30, 70);
            end
            mon.run();
        join_any
        $display("write-read test complete.");
        mon.reset();
    endtask

    initial
        begin
            reset();

            test_write();
            // test_write_more();
            // test_read();
            // test_read_more();
            // test_write_read();

            $display("simulation is complete");
            $finish();
        end

endmodule