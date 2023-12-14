`timescale 1ps/1ps

module  tb_AddressGenerator;

    reg clk, rst;
    wire [7:0] memAddress;
    wire wrMode;
    //wire integer pivot1;
    integer i;

    AddressGenerator uut (
        .clk(clk),
        .rst(rst),
        .memAddress(memAddress),
        .wrMode(wrMode)
    );
    initial begin
        clk = 0;
        rst = 0;
    end
    initial begin
        for (i = 0; i < 20000; i = i + 1) begin
            #10 clk = ~clk;
        end
        $finish;
    end

endmodule