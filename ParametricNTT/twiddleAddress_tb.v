`timescale 1ps/1ps

module  twiddleAddress_tb;

    reg clk, rst, done;
    wire [6:0] twiddleAddress;
    wire [7:0] rdAddress, wrAddress;
    wire wrValid;
    
    //wire integer pivot1;
    integer i;

    //AddressGenerator2 (clk, rst, done, rdAddress, wrAddress, wrValid)
    /*
    AddressGenerator2 uut (
        .clk(clk),
        .rst(rst),
        .done(done),
        .rdAddress(rdAddress),
        .wrAddress(wrAddress),
        .wrValid(wrValid)
    ); */

    TwiddleAddressGenerator uut (
        .clk(clk),
        .rst(rst),
        .done(done),
        .twiddleAddress(twiddleAddress)
    );

    AddressGenerator2 uut1 (
        .clk(clk),
        .rst(rst),
        .done(done),
        .rdAddress(rdAddress),
        .wrAddress(wrAddress),
        .wrValid(wrValid)
    );



    initial begin
        clk = 0;
        rst = 0;
        done = 0;
    end
    initial begin
        for (i = 0; i < 20000; i = i + 1) begin
            #10 clk = ~clk;
            if (i == 20) begin
                done = 1;
            end 
        end
        $finish;
    end

endmodule