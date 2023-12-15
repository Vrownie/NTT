`timescale 1ps/1ps

module  tb_AddressGenerator;

    reg clk, rst, done;
    wire [7:0] rdAddress, wrAddress;
    wire wrValid;
    //wire integer pivot1;
    integer i;

    //AddressGenerator2 (clk, rst, done, rdAddress, wrAddress, wrValid)

    AddressGenerator2 uut (
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