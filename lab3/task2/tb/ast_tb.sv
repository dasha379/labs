`timescale 1ns/1ps

module ast_tb;
    import ast_pkg::*;
    parameter int DATA_IN_W   = 64;
    parameter int DATA_OUT_W  = 256;
    parameter int EMPTY_IN_W  = $clog2(DATA_IN_W/8);
    parameter int EMPTY_OUT_W = $clog2(DATA_OUT_W/8);
    parameter int CHANNEL_W   = 10;
    localparam int MAX_SIZE   = 65536;

    bit clk_i, srst_i;

    initial
        begin
            clk_i = '0;
            forever #5 clk_i = ~clk_i;
        end

    ast_interface #(
        .DATA_IN_W  (DATA_IN_W),
        .DATA_OUT_W (DATA_OUT_W),
        .EMPTY_IN_W (EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W  (CHANNEL_W)
    ) intf (
        .clk_i (clk_i),
        .srst_i(srst_i)
    );

    ast_width_extender # (
        .DATA_IN_W  (DATA_IN_W),
        .DATA_OUT_W (DATA_OUT_W),
        .EMPTY_IN_W (EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W  (CHANNEL_W)
    ) DUT (
        .clk_i              (clk_i),
        .srst_i             (srst_i),
        .ast_data_i         (intf.ast_data_i),
        .ast_startofpacket_i(intf.ast_startofpacket_i),
        .ast_endofpacket_i  (intf.ast_endofpacket_i),
        .ast_valid_i        (intf.ast_valid_i),
        .ast_empty_i        (intf.ast_empty_i),
        .ast_channel_i      (intf.ast_channel_i),
        .ast_ready_o        (intf.ast_ready_o),
        .ast_data_o         (intf.ast_data_o),
        .ast_startofpacket_o(intf.ast_startofpacket_o),
        .ast_endofpacket_o  (intf.ast_endofpacket_o),
        .ast_valid_o        (intf.ast_valid_o),
        .ast_empty_o        (intf.ast_empty_o),
        .ast_channel_o      (intf.ast_channel_o),
        .ast_ready_i        (intf.ast_ready_i)
    );

    mailbox#(ast_transaction) gen2drv = new();
    mailbox#(ast_transaction) gen2chk = new();

    ast_generator #(
        .DATA_IN_W  (DATA_IN_W),
        .DATA_OUT_W (DATA_OUT_W),
        .EMPTY_IN_W (EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W  (CHANNEL_W)
    ) gen = new(gen2drv);

    ast_driver #(
        .DATA_IN_W  (DATA_IN_W),
        .DATA_OUT_W (DATA_OUT_W),
        .EMPTY_IN_W (EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W  (CHANNEL_W)
    ) drv = new(intf, gen2drv, gen2chk);

    ast_checker #(
        .DATA_IN_W  (DATA_IN_W),
        .DATA_OUT_W (DATA_OUT_W),
        .EMPTY_IN_W (EMPTY_IN_W),
        .EMPTY_OUT_W(EMPTY_OUT_W),
        .CHANNEL_W  (CHANNEL_W)
    ) chk = new(intf, gen2chk);

    task reset();
        srst_i <= '1;
        repeat (2) @ (posedge clk_i);
        srst_i <= '0;
    endtask

    task automatic test(int valid_pr);
        int small_1   = 3;
        int small_2   = 3;
        int max       = 2;
        int random    = 2;
        int empty_en  = 2;
        int empty_dis = 2;
        int total = small_1 + small_2 + max + random + empty_dis + empty_en;
        fork
            gen.run(small_1, small_2, max, random, empty_en, empty_dis);
            drv.run(valid_pr, total);
            chk.run(total);
        join
    endtask

    initial
        begin
            reset();
            test(100);
            //test(0);
            //test(70);

            $display("simulation is complete");
            $finish();
        end


endmodule