`include "defines.v"

module PE_Tilde( 
	input clk, reset,
	input start,
	input [`DATA_SIZE_ARB-1:0] q, data_top_i, data_bot_i, twiddle_i,
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

	// inferred registers
	logic [`DATA_SIZE_ARB-1:0] twiddle_q, msub_res_q, madd_res_q;

	always_ff @(posedge clk) begin
		if (reset) begin
			twiddle_q  <= 0;
			msub_res_q <= 0;
			madd_res_q <= 0;
		end else begin
			twiddle_q  <= twiddle_i;
			msub_res_q <= msub_res;
			madd_res_q <= madd_res;
		end
	end

	logic [`DATA_SIZE_ARB-1:0] mult_out;
	ModMult mult (
		.clk(clk), .reset(reset),
        .A(twiddle_q), .B(msub_res_q),
        .q(q), .C(mult_out)
	);
	
	logic [`DATA_SIZE_ARB-1:0] delayed_add_out;
	shift_reg #(
		.STAGES(`INTMUL_DELAY + `MODRED_DELAY),
		.WIDTH(`DATA_SIZE_ARB)
	) delay_input (
		.clk(clk), .reset(reset),
		.data_i(madd_res_q), .data_o(delayed_add_out)
	);

	// infer another reg for bot_out, top_out is fine
	assign ntt_top_o = delayed_add_out;
	assign ntt_bot_o = mult_out;

endmodule
