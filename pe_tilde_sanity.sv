`timescale 1ns/1ps

module ntt_tb();

`include "defines.v"

logic clk, reset;
logic [`DATA_SIZE_ARB-1:0] q, data_top_i, data_bot_i, twiddle_i;
logic [`DATA_SIZE_ARB-1:0] ntt_top_o, ntt_bot_o; 

integer fh_in, fh_out, index;

PE_Tilde dut(
    .clk(clk), .reset(reset), .q(q), 
    .data_top_i(data_top_i), .data_bot_i(data_bot_i), 
    .ntt_top_o(ntt_top_o), .ntt_bot_o(ntt_bot_o)
);


// initial begin
//   fh_in  = $fopen("test/6950_PE_SANITY.txt", "r");
//   fh_out = $fopen("pe_tilde_sanity.txt","w");
// end

assign q = `DATA_SIZE_ARB'h1e01;
assign data_top_i = `DATA_SIZE_ARB'd1147;
assign data_bot_i = `DATA_SIZE_ARB'd2963;

// Set intial values and reset the module
initial begin
	clk = 1'b0;
	reset = 1'b1;

	#20
    reset = 1'b0;
end

// toggle clk at ClkPeriod/2
always #(2) clk = ~clk;

// always @(posedge clk) begin
// 	if (reset == 1'b0) begin
// 		valid <= 1'b1;
// 		$fscanf(fh_in,"%h \n",NTTin0);
    	
//     	### Added Numstages for the pipelined design ###
//       	if ($feof(fh_in)) begin
//         	//$fclose(fh_out);
//             $fclose(fh_in);
//             //$finish;
// 			valid = 1'b0;
//         end  
// 	end
// end

always #100 $stop(0);

endmodule


