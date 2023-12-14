`include "defines.v"


module Reorder_Out #(
    parameter NUM_STAGES = 4
)
(
    input clk, reset, next_pair, 
    output logic [NUM_STAGES-1:0] wr_addr_top, wr_addr_bot, rd_addr, 
    output logic in_done, out_done
);

    logic [NUM_STAGES-2:0] counter; 
    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            wr_addr_bot <= 0;
            wr_addr_top <= 0;
            rd_addr <= 0;
            in_done <= 0;
            out_done <= 0;
        end else begin
            if (!in_done && next_pair) begin
                counter <= counter + 1;
                wr_addr_top <= {1'b0, ~counter[0], counter[NUM_STAGES-2:1]};
                wr_addr_bot <= {1'b1, ~counter[0], counter[NUM_STAGES-2:1]};
                if (!(~counter)) begin
                    in_done <= 1;
                end
            end else if (in_done && !out_done) begin
                rd_addr <= rd_addr + 1;
                if (!(~rd_addr)) begin
                    out_done <= 1;
                end
            end
        end
    end

endmodule
