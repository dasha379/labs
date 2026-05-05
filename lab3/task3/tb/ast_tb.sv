`timescale 1ns/1ps

module ast_tb;
    import ast_pkg::*;
    parameter int DATA_WIDTH = 64;
    parameter int EMPTY_WIDTH = $clog2(DATA_WIDTH/8);
    parameter int CHANNEL_WIDTH = 8;
    parameter int TX_DIR = 4;
    localparam int MAX_SIZE = 65536;
    localparam int TX_DIR_W = $clog2(TX_DIR);

    bit clk_i, srst_i;

    initial
        begin
            clk_i = '0;
            forever #5 clk_i = ~clk_i;
        end

    ast_interface_dir # (.DIR_W(TX_DIR_W)) dir_intf (
        .clk(clk_i),
        .rst(srst_i)
    );

    ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf_out [TX_DIR - 1 : 0] (
        .clk_i (clk_i),
        .srst_i(srst_i)
    );

    ast_interface #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) intf_in (
        .clk_i (clk_i),
        .srst_i(srst_i)
    );

    logic [DATA_WIDTH    - 1 : 0] ast_data_o          [TX_DIR-1:0];
    logic                         ast_startofpacket_o [TX_DIR-1:0];
    logic                         ast_endofpacket_o   [TX_DIR-1:0];
    logic                         ast_valid_o         [TX_DIR-1:0];
    logic [EMPTY_WIDTH   - 1 : 0] ast_empty_o         [TX_DIR-1:0];
    logic [CHANNEL_WIDTH - 1 : 0] ast_channel_o       [TX_DIR-1:0];
    logic                         ast_ready_i         [TX_DIR-1:0];

    genvar i;
    generate
        for (i = 0; i < TX_DIR; ++i)
        begin
            assign intf_out[i].ast_data = ast_data_o[i];
            assign intf_out[i].ast_startofpacket = ast_startofpacket_o[i];
            assign intf_out[i].ast_endofpacket = ast_endofpacket_o[i];
            assign intf_out[i].ast_valid = ast_valid_o[i];
            assign intf_out[i].ast_empty = ast_empty_o[i];
            assign intf_out[i].ast_channel = ast_channel_o[i];
            assign ast_ready_i[i] = intf_out[i].ast_ready;
        end
    endgenerate

    ast_dmx # (
        .DATA_WIDTH         (DATA_WIDTH),
        .EMPTY_WIDTH        (EMPTY_WIDTH),
        .TX_DIR             (TX_DIR),
        .CHANNEL_WIDTH      (CHANNEL_WIDTH),
        .DIR_SEL_WIDTH      (TX_DIR_W)
    ) DUT (
        .clk_i              (clk_i),
        .srst_i             (srst_i),
        .dir_i              (dir_intf.dir_i),
        .ast_data_i         (intf_in.ast_data),
        .ast_startofpacket_i(intf_in.ast_startofpacket),
        .ast_endofpacket_i  (intf_in.ast_endofpacket),
        .ast_valid_i        (intf_in.ast_valid),
        .ast_empty_i        (intf_in.ast_empty),
        .ast_channel_i      (intf_in.ast_channel),
        .ast_ready_o        (intf_in.ast_ready),
        .ast_data_o         (ast_data_o),
        .ast_startofpacket_o(ast_startofpacket_o),
        .ast_endofpacket_o  (ast_endofpacket_o),
        .ast_valid_o        (ast_valid_o),
        .ast_empty_o        (ast_empty_o),
        .ast_channel_o      (ast_channel_o),
        .ast_ready_i        (ast_ready_i)
    );

    mailbox#(ast_transaction) gen2drv = new();
    mailbox#(ast_transaction) drv2chk = new();
    mailbox#(ast_transaction) mon2chk = new();

    ast_generator #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .TX_DIR        (TX_DIR),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) gen = new(gen2drv);

    ast_driver #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .TX_DIR        (TX_DIR),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) drv = new(intf_in, dir_intf, gen2drv, drv2chk);

    ast_monitor # (
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .CHANNEL_WIDTH (CHANNEL_WIDTH),
        .TX_DIR        (TX_DIR)
    ) mon = new(intf_out, mon2chk);

    ast_checker #(
        .DATA_WIDTH    (DATA_WIDTH),
        .EMPTY_WIDTH   (EMPTY_WIDTH),
        .TX_DIR        (TX_DIR),
        .CHANNEL_WIDTH (CHANNEL_WIDTH)
    ) chk = new(drv2chk, mon2chk);

    task reset();
        srst_i <= '1;
        repeat (2) @ (posedge clk_i);
        srst_i <= '0;
    endtask

    task automatic test(int valid_pr);
        int total = 5;
        fork
            begin
                repeat (5) begin 
                gen.run(DATA_WIDTH / 8, 1);
                repeat (5) @ (posedge clk_i);end
                //gen.run(MAX_SIZE, 1);
                // gen.run($urandom_range(DATA_WIDTH / 8, MAX_SIZE - 1), TX_DIR_W'($urandom()));
                // gen.run($urandom_range(1, DATA_WIDTH/8), TX_DIR_W'($urandom()));
            end
            drv.run(valid_pr, total);
            mon.run(total);
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