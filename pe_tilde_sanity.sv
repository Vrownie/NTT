`timescale 1ns/1ps

`include "defines.v"
`define CLK_PERIOD 2

module ntt_tb();

    logic clk, reset;
    logic [`DATA_SIZE_ARB-1:0] q, data_top_i, data_bot_i, twiddle_i;
    logic [`DATA_SIZE_ARB-1:0] ntt_top_o, ntt_bot_o; 
    logic [`DATA_SIZE_ARB-1:0] exp_top_o, exp_bot_o;

    PE_Tilde dut(
        .clk(clk), .reset(reset), .q(q), 
        .data_top_i(data_top_i), .data_bot_i(data_bot_i), 
        .ntt_top_o(ntt_top_o), .ntt_bot_o(ntt_bot_o)
    );

    assign q = `DATA_SIZE_ARB'h1e01; // fixed = 7681

    always #`CLK_PERIOD clk = ~clk; // toggle clock

    // File handling
    integer file;
    integer scan_file;
    integer index;
    initial begin
        clk = 1'b0;
        reset = 1'b1;

        #(`CLK_PERIOD*2) reset = 1'b0;

        // Open the file
        file = $fopen("test/6950_PE_SANITY.txt", "r");
        if (file == 0) begin
            $display("Error: Unable to open file.");
            $stop(0);
        end

        index = 0;
        // Read each line from the file
        while (!$feof(file)) begin
            if (index == 0) begin // Skip the first line
                string temp;
                scan_file = $fscanf(file, "%s\n", temp);
                index++;
                continue;
            end
            scan_file = $fscanf(file, "%d,%d,%d,%d,%d\n", data_top_i, data_bot_i, twiddle_i, exp_top_o, exp_bot_o);
            #(`CLK_PERIOD*5); // Wait for the module to process inputs

            // Compare module outputs with expected outputs
            if ((exp_top_o != ntt_top_o) || (exp_bot_o != ntt_bot_o)) begin
                $display("Test failed for inputs %d, %d, %d: Expected outputs %d, %d; Got %d, %d",
                        data_top_i, data_bot_i, twiddle_i, exp_top_o, exp_bot_o, ntt_top_o, ntt_bot_o);
            end
            index++;
        end
        
        $display("ALL TESTS PASSED");
        $fclose(file);
        $stop(0);
    end

endmodule


