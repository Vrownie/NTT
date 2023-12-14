`include "defines.v"

module top (
    input clk, reset, valid,
	input [`DATA_SIZE_ARB-1:0] q, data_i,
    input [`DATA_SIZE_ARB-1:0] data_o,
);

    logic ram1_re, ram2_re, done;
    logic sel_a1, sel_a2, sel_b1, sel_b2;
    logic [`DATA_SIZE_ARB-1:0] bit_rev_o, top_ram_o, bot_ram_o;
    logic [`DATA_SIZE_ARB-1:0] pe1_o, data_top;
    logic we_top, we_bot; //Write enable for to and bottom RAMs
    logic [$clog2(`RING_SIZE)-1:0] wraddr_top, wraddr_bot;
    logic [$clog2(`RING_SIZE)-1:0] addr_rd_top, addr_wr_top;


    bit_reverse BR (
        .clk(clk), .reset(reset), .valid(valid),
        .din(data_i), .dout(bit_rev_o),
        .ram1_re(ram1_re), .ram2_re(ram2_re), .done(done),
        .addr(br_addr)
    );

    module AddressGenerator_s (.clk(clk), .rst(rst), .memAddress()., wrMode);


    always @* begin
        if (!done) begin
            wraddr_top = br_addr;
            we_top = ram1_re;            

            wraddr_bot = br_addr;
            we_bot = ram2_re;    
            
            data_top = bit_rev_o;   
        end
        else begin
            wr_top = br;
            wr_bot = ram2_re;
            we_bot
        end
    end

    PE PE1 ( 
        .clk(clk), .reset(reset),
        .start(done), .sel_a(sel_a1), .sel_b(sel_b1),
        .q(q), .data_i(top_ram_o),
        .twiddle_i(twiddle_i), .ntt_o(pe1_o)
    );

    BRAM #(DATA_SIZE_ARB, RING_SIZE/2) 
    top_ram
           (.clk(clk), .wen(we_top),
            .waddr(wraddr_top), .din(),
            .raddr(), .dout(top_ram_o)
    );
    
endmodule

