module TwiddleAddressGenerator(clk, rst, done, twiddleAddress);
    parameter numberStages = 8;
    input clk, rst, done;
    output reg [numberStages-2:0] twiddleAddress;
    logic [numberStages-2:0] pivot = {{(numberStages-2){1'b0}},1'b1};
    logic [numberStages - 2: 0] counter = {(numberStages-1){1'b0}};
    logic [numberStages-2:0] twiddleAddressHelper = {(numberStages-1){1'b1}};
    logic [numberStages-2:0] twiddleAddressHelper1 = {(numberStages-1){1'b1}};
    logic divided;
    logic clockDelay = 0;
    ClockDivider myClk(.clk(clk), .clk_out(divided));
    logic [numberStages-2:0] pivotDelay;

   
    always_ff@(posedge clk) begin
        twiddleAddressHelper1 <= twiddleAddressHelper;
    end


    always_ff @(posedge divided or posedge rst) begin 
        if(rst) begin
            twiddleAddressHelper <= {(numberStages-1){1'b0}};
            counter <= {(numberStages){1'b0}};
        end else if (done) begin
            counter <= counter + 1'b1; //increment the counter
            twiddleAddressHelper <= twiddleAddressHelper + pivotDelay;          
            if (counter == {(numberStages-1){1'b1}}) begin //if we reach the end of the read/write cycle --> restart it
                if (pivot == {(numberStages-1){1'b0}}) begin
                    pivot <= { {(numberStages-2){1'b0}}, 1'b1};
                end else begin
                    pivot <= pivot << 1;
                end
               // twiddleAddressHelper <= {(numberStages-1){1'b0}};
            end
             
        end
        pivotDelay <= pivot;
    end

    assign twiddleAddress = twiddleAddressHelper1;

endmodule


module ClockDivider (
      clk,
      clk_out
);
    input clk;
    output reg clk_out;
    reg flip = 1'b0;

    always @(posedge clk) begin
        flip <= ~flip;
    end

    assign clk_out = flip;

endmodule