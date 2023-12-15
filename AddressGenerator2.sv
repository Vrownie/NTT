module AddressGenerator2 (clk, rst, done, rdAddress, wrAddress, wrValid, last_statge);
    parameter numStages = 8; //number of log2(Ring Size) of inputs
    localparam delay = 11;
    input clk;
    input rst;
    input done;
    output reg [numStages - 1:0] rdAddress; //address in memory being modified
    output reg [numStages - 1:0] wrAddress;
    output reg wrValid;
    output reg last_stage;
    //output wrMode;

    logic last_stage_temp;
    logic internalCounter = 1'b0;
    int pivot = numStages-1;
    logic [numStages - 1: 0] memAddress1 = {1'b1,  {(numStages-1){1'b0}}}; //create the upper mem address
    logic [numStages - 1: 0] memAddress2 = {(numStages){1'b0}}; //create the lower mem address
    logic init = 1'b1;
    logic [numStages - 1: 0] memAddressHelper;
    logic [numStages - 1: 0] nextMemAddress1, nextMemAddress2;
    logic [numStages - 1: 0] memoryAddressShiftReg [delay-1:0];
    logic wrValidHelper = 0;

    always_comb begin
        if (pivot == 1)
            last_stage = 1'b1;
        else
            last_statge = 1'b0;
    end
    
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            internalCounter <= 1'b0;
            init = 1'b1;
            memAddress1 <= {1'b1,  {(numStages-1){1'b0}}};
            memAddress2 <= {(numStages){1'b0}};
        end else if (done) begin //
            if (internalCounter == 1'b0) begin
                internalCounter <= 1'b1;
                if (init == 1'b1) begin //if we are just starting the code, dont do anything
                    init <= 1'b0;
                end else begin
                    if (nextMemAddress2[pivot] == 1'b1) begin //so if we reached the next pivot point on the lower bits
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
            end else begin //internal counter is 1
                internalCounter <= internalCounter - 1'b1; //increment the cycle counter
                nextMemAddress1 <= memAddress1 + 1'b1; //increment the upper address
                nextMemAddress2 <= memAddress2 + 1'b1; //increment the lower address 
            end
        end
        memAddressHelper <= (internalCounter == 1'b1) ? memAddress1 : memAddress2;
        memoryAddressShiftReg <= {memAddressHelper, memoryAddressShiftReg[delay-1:1]};
        if (memoryAddressShiftReg[1] != 0 && wrValidHelper == 1'b0) begin
            wrValidHelper <= 1'b1;
        end

    end

    assign rdAddress = memAddressHelper;
    assign wrAddress = memoryAddressShiftReg[0];
    assign wrValid = wrValidHelper;

endmodule