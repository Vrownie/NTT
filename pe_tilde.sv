`include "defines.v"

module PE_Tilde( 
	input clk, reset,
	input [`DATA_SIZE_ARB-1:0] q, data_top_i, data_bot_i, 
	output logic [`DATA_SIZE_ARB-1:0] ntt_top_o, ntt_bot_o
);

	// modular add
	logic        [`DATA_SIZE_ARB  :0] madd;
	logic signed [`DATA_SIZE_ARB+1:0] madd_q;
	logic        [`DATA_SIZE_ARB-1:0] madd_res;

	assign madd     = data_top_i + data_bot_i;
	assign madd_q   = madd - q;
	assign madd_res = (madd_q[`DATA_SIZE_ARB+1] == 1'b0) ? madd_q[`DATA_SIZE_ARB-1:0] : madd[`DATA_SIZE_ARB-1:0];

	// modular sub
	logic        [`DATA_SIZE_ARB  :0] msub;
	logic signed [`DATA_SIZE_ARB+1:0] msub_q;
	logic        [`DATA_SIZE_ARB-1:0] msub_res;

	assign msub     = data_top_i - data_bot_i;
	assign msub_q   = msub + q;
	assign msub_res = (msub[`DATA_SIZE_ARB] == 1'b0) ? msub[`DATA_SIZE_ARB-1:0] : msub_q[`DATA_SIZE_ARB-1:0];

	// ???
	assign ntt_top_o = madd_res;
	assign ntt_bot_o = msub_res;

endmodule
