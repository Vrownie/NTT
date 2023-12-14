module AddressGenerator (clk, rst, memAddress, wrMode, done);
    parameter numStages = 8; //number of stages in the pipeline
    input clk;
    input rst;
    input done;
    output [numStages - 1:0] memAddress; //address in memory being modified
    output wrMode; //is it write or read mode
    //output int pivot1;

    //logic [numStages: 0] upperAddress, lowerAddress;
    //logic [numStages - 1: 0] pivot = {1'b1,  {(numStages-1){1'b0}}};
    logic [1:0] internalCounter = 2'b00;// use to keep track of which stage of read/write
    int pivot = numStages-1;
    logic [numStages - 1: 0] memAddress1 = {1'b1,  {(numStages-1){1'b0}}}; //create the upper mem address
    logic [numStages - 1: 0] memAddress2 = {(numStages){1'b0}}; //create the lower mem address
    logic init = 1'b1;
    logic [numStages - 1: 0] memAddressHelper;
    logic [numStages - 1: 0] nextMemAddress1, nextMemAddress2;
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            internalCounter <= 2'b00;
            init = 1'b1;
            memAddress1 <= {1'b1,  {(numStages-1){1'b0}}};
            memAddress2 <= {(numStages){1'b0}};
        end
        else if (done) begin //we are on clk
            if (internalCounter == 2'b11) begin //if we reach the end of the read/write cycle --> restart it
                internalCounter <= 2'b00;
                nextMemAddress2 <= memAddress2 + 1'b1; //increment the lower address
                nextMemAddress1 <= memAddress1 + 1'b1; //increment the upper address
            end
            else begin
                internalCounter <= internalCounter + 1'b1; //increment the cycle counter
            end


            if (internalCounter == 2'b00) begin //if we are at the start of a new readwrite cycle 
                if (init == 1'b1) begin //if we are just starting the code, dont do anything
                    init <= 1'b0;
                end
                else begin
                    if (nextMemAddress2[pivot] == 1'b1) begin //so if we reached the next pivot point on the lower bits
                    //if our upper address has reached the maximum value
                    //shift the pivot to the next bit
                    // reset the lower address to 0
                    // set the upper address to 000 1 at pivot 000 after pivot

                        if(nextMemAddress1 == {numStages{1'b0}}) begin //if we maxed out the memory addresses (finished this layer)
                            if (pivot == 0) begin //if weve gone throguh every single computation, restart from the top
                                pivot = numStages-1;
                                memAddress1 <= {1'b1,  {(numStages-1){1'b0}}};
                                memAddress2 <= {(numStages){1'b0}};
                            end else begin //shift the pivot point over one
                                pivot = pivot - 1;
                                //lower memAdress starts at 0
                                memAddress2 <= {(numStages){1'b0}};
                                //upper memAddress starts at 000 1 at pivot 000 after pivot
                                //memAddress1 <= {(numStages-1-pivot-1){1'b0}, 1'b1, (pivot-1){1'b0}}; //create the upper mem address
                                //memAddress1 <= {}
                                memAddress1 <=  1'b1 << pivot;
                                
                                 /*1'b1 << (pivot);*/ /*{{(numStages-1-pivot){1'b0}}, 1'b1, {(pivot){1'b0}}};*/ //create the upper mem address
                            end
                        end else begin //not moving the pivot but reseting the lower and upper addresses 
                            //so the pivot bit 
                            memAddress2 <= memAddress1 + 1;
                            memAddress1 <= memAddress1 + 1 + (1'b1 << (pivot));
                        end
                        
                    end else begin
                        memAddress2 <= memAddress2 + 1'b1; //increment the lower address
                        memAddress1 <= memAddress1 + 1'b1; //increment the upper address
                    end  
                end

            end

        end
        memAddressHelper <= (internalCounter[0] == 1'b1) ? memAddress1 : memAddress2;

    end

    /*always_comb begin 
        memAddress = (internalCounter[0] == 1'b0) ? memAddress1 : memAddress2;
    end*/

    assign wrMode = internalCounter[1];
    assign memAddress = memAddressHelper;
    /*assign pivot1 = pivot;
    assign nextMemAddress2_out = nextMemAddress2;
    assign nextMemAddress1_out = nextMemAddress1;*/

endmodule