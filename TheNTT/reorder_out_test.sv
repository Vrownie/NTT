`timescale 1ns/1ps

`include "defines.v"
`define CLK_PERIOD 2
`define STAGES 4

module reorder_out_tb();

    logic clk, reset, next_pair;
    logic [`STAGES-1:0] wr_addr_top, wr_addr_bot, rd_addr; 
    logic in_done, out_done;

    Reorder_Out #(.NUM_STAGES(`STAGES)) dut (
        .clk(clk), .reset(reset), .next_pair(next_pair),
        .wr_addr_top(wr_addr_top), .wr_addr_bot(wr_addr_bot), .rd_addr(rd_addr), 
        .in_done(in_done), .out_done(out_done)
    );

    always #(`CLK_PERIOD/2) clk = ~clk; // toggle clock

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        #(`CLK_PERIOD*2);
        reset = 1'b0;

        for (int i = 0; i < 100; i++) begin
            #(`CLK_PERIOD*5) next_pair = 1'b1;
            #(`CLK_PERIOD) next_pair = 1'b0;
        end

        #(`CLK_PERIOD*100) $stop(0);
    end

endmodule
