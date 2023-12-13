`include "defines.v"

module contoller( 
    input clk, reset,
    input start,
    output sel_a, sel_b, sel_ram,
    output [11:0] stage
);
    localparam  delay = 11;
    logic [7:0] counter = 8'b0, delay_count = 0;

    //Number of operations before final stage outputs
    //logic [`DATA_SIZE_ARB-1:0] last_stage_count = RING_SIZE*($clog2(`RING_SIZE)-1);
    logic [11:0] stage_count = 1;
    logic temp_sel_a, temp_sel_b, temp_sel_ram;

    typedef enum {idle=0, mux_1=1, mux_2=2} state;
    state current_state = idle, next_state;

    always_ff @(posedge clk) begin
        if (reset)
            current_state <= idle;
        else
            current_state <= next_state;
    end

    always_comb begin
        case (current_state)
            idle: begin
                temp_sel_a = 1'b1;
                temp_sel_b = 1'b1;
                if (delay_count == delay)
                    next_state = mux_1;
            end

            mux_1: begin
                temp_sel_a = 1'b1;
                temp_sel_b = 1'b0;
                //One clock cycle after all calculations are completed return to idle state
                //if (counter == last_stage_count + `RING_SIZE/2 +1)
                next_state = mux_2;
            end

            mux_2: begin
                temp_sel_a = 1'b0;
                temp_sel_b = 1'b1;
                next_state = mux_1;
            end
        endcase
    end

    assign sel_a = temp_sel_a;
    assign sel_b = temp_sel_b;
    assign sel_ram = temp_sel_ram;

    always_comb begin
        //Select Ram input from Bit_reverse fr
        if (counter >= `RING_SIZE/2)
            temp_sel_ram = 1'b0;
        else 
            temp_sel_ram = 1'b1;    
    end

    always_ff @ (posedge clk) begin    
        if (start) begin
            counter <= counter + 1'b1;
            delay_count <= delay_count + 1'b1;
            //While not on last stage count half of inputs
            if (stage_count < $clog2(`RING_SIZE)) begin
                if (counter >= `RING_SIZE/2-1)
                   counter <= 0;
                if (counter == `RING_SIZE/2-1)
                    stage_count <= stage_count + 1'b1;
            end
            //When in final stage after final output reset counter and stage count
            else begin
                if (counter >= `RING_SIZE-1) begin
                    counter <= 0;
                    stage_count <= 0;
                end
            end
        end

    end

endmodule