`include "defines.v"

module top (
    input clk, reset, valid,
	input [`DATA_SIZE_ARB-1:0] q, data_i, twiddle_i,
    output reg [`DATA_SIZE_ARB-1:0] data_o,
    output reg is_done
);

    `define ADDR_SIZE $clog2(`RING_SIZE)

    logic ram1_re, ram2_re, done;
    logic sel_a1, sel_a2, sel_ram_redundant;
    logic [`DATA_SIZE_ARB-1:0] bit_rev_o, top_ram_o, bot_ram_o;
    logic [`DATA_SIZE_ARB-1:0] pe1_o, pe2_o;
    logic [11:0] count = 0;
    logic last_stage;

    
    //Signals for to and bottom RAMs
    logic we_top, we_bot, addgen_wr; 
    logic [`ADDR_SIZE-1:0] wr_addr_br, rd_addr_br; //Signals from bit reverse
    logic [`ADDR_SIZE-1:0] wr_addr_addgen, rd_addr_addgen; //Signals from address generator
    logic [`ADDR_SIZE-1:0] rd_addr, wr_addr;
    logic [`DATA_SIZE_ARB-1:0] top_ram_i, bot_ram_i;

    //Final Stage
    logic [`DATA_SIZE_ARB-1:0] last_pe_top, last_pe_bot;
    logic [`ADDR_SIZE-1:0] reorder_wr_addr_top, reorder_wr_addr_bot, reorder_rd_addr;
    logic in_done, out_done;
    logic [`DATA_SIZE_ARB-1:0] last_ram_top_o, last_ram_bot_o;

    bit_reverse BR (
        .clk(clk), .reset(reset), .valid(valid),
        .din(data_i), .dout(bit_rev_o),
        .ram1_re(ram1_re), .ram2_re(ram2_re), .done(done),
        .addr(br_addr)
    );

    AddressGenerator2 AddrGen(.clk(clk), .rst(reset), .done(done), .rdAddress(rd_addr_addgen),
                             .wrAddress(wr_addr_addgen), .wrValid(addgen_wr), .last_statge());

    contoller control( 
        .clk(clk), .reset(reset),
        .start(done), .sel_a(sel_a1), .sel_b(sel_a2), 
        .sel_ram(sel_ram_redundant), .stage(count)
    );

    always @* begin
        if (!done) begin
            wr_addr = wr_addr_br;
            we_top = ram1_re;            
            we_bot = ram2_re;   
            top_ram_i = bit_rev_o;
            bot_ram_i = bit_rev_o;
        end
        else begin
            wr_addr = wr_addr_addgen;
            we_top = addgen_wr;            
            we_bot = addgen_wr;
            top_ram_i = pe1_o;
            bot_ram_i = pe2_o;
        end
    end

    //PE and Block RAM first Pair
    BRAM #(`DATA_SIZE_ARB, `RING_SIZE/2) 
    top_ram(
        .clk(clk), .wen(we_top),
        .waddr(wr_addr), .din(top_ram_i),
        .raddr(rd_addr_addgen), .dout(top_ram_o)
    );

    PE PE1 ( 
        .clk(clk), .reset(reset),
        .start(done), .sel_a(sel_a1), .sel_b(sel_b1),
        .q(q), .data_i(top_ram_o),
        .twiddle_i(twiddle_o), .ntt_o(pe1_o)
    );

    //PE and Block RAM second Pair
    BRAM #(`DATA_SIZE_ARB, `RING_SIZE/2) 
    bot_ram(
        .clk(clk), .wen(we_top),
        .waddr(wr_addr), .din(bot_ram_i),
        .raddr(rd_addr_addgen), .dout(bot_ram_o)
    );

    PE PE2 ( 
        .clk(clk), .reset(reset),
        .start(done), .sel_a(sel_a1), .sel_b(sel_b1),
        .q(q), .data_i(bot_ram_o),
        .twiddle_i(twiddle_o), .ntt_o(pe2_o)
    );

    //Final Stage
    PE_Tilde final_PE( 
        .clk(clk), .reset(reset),
        .q(q), .data_top_i(pe1_o), .data_bot_i(pe2_o), 
        .ntt_top_o(last_pe_top), .ntt_bot_o(last_pe_bot)
    );

    Reorder_Out #(ADDR_SIZE) reorder(
        .clk(clk), .reset(reset), .next_pair(last_stage), 
        .wr_addr_top(reorder_wr_addr_top), 
        .wr_addr_bot(reorder_wr_addr_bot), 
        .rd_addr(reorder_rd_addr), 
        .in_done(in_done), .out_done(out_done)
    );

    // manually create 2-write 1-read BRAM with MSB toggling
    BRAM #(`DATA_SIZE_ARB, `RING_SIZE/2) 
    last_ram_top(
        .clk(clk), .wen(1'b1),
        .waddr(reorder_wr_addr_top[`ADDR_SIZE-2:0]), .din(last_pe_top),
        .raddr(reorder_rd_addr[`ADDR_SIZE-2:0]), .dout(top_ram_o)
    );

    BRAM #(`DATA_SIZE_ARB, `RING_SIZE/2) 
    last_ram_bot(
        .clk(clk), .wen(1'b1),
        .waddr(reorder_wr_addr_bot[`ADDR_SIZE-2:0]), .din(last_pe_bot),
        .raddr(reorder_rd_addr[`ADDR_SIZE-2:0]), .dout(bot_ram_o)
    );

    // mux out of 2 BRAMs
    always @* begin
        if (reorder_rd_addr[`ADDR_SIZE-1]) begin
            data_o = bot_ram_o;
        end else begin
            data_o = top_ram_o;
        end
    end

    assign is_done = out_done;
    
endmodule

