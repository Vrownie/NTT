`include "defines.v"

module PE( 
	input clk, reset,
	input start, sel_a, sel_b,
	input [`DATA_SIZE_ARB-1:0] q, data_i,
	input [`DATA_SIZE_ARB-1:0] twiddle_i,
	output [`DATA_SIZE_ARB-1:0] ntt_o
);

	logic [`DATA_SIZE_ARB-1:0] mux1_out, mux2_out, mult_out, data_i_shifted;
	logic [`DATA_SIZE_ARB-1:0] even_out, odd_out;

	// modular add
	logic        [`DATA_SIZE_ARB  :0] madd;
	logic signed [`DATA_SIZE_ARB+1:0] madd_q;
	logic        [`DATA_SIZE_ARB-1:0] madd_res;

	assign madd     = mux1_out + odd_out;
	assign madd_q   = madd - q;
	assign madd_res = (madd_q[`DATA_SIZE_ARB+1] == 1'b0) ? madd_q[`DATA_SIZE_ARB-1:0] : madd[`DATA_SIZE_ARB-1:0];

	// modular sub
	logic        [`DATA_SIZE_ARB  :0] msub;
	logic signed [`DATA_SIZE_ARB+1:0] msub_q;
	logic        [`DATA_SIZE_ARB-1:0] msub_res;
	logic 		 [5:0] counter = 6'b0;

	assign msub     = mux1_out - odd_out;
	assign msub_q   = msub + q;
	assign msub_res = (msub[`DATA_SIZE_ARB] == 1'b0) ? msub[`DATA_SIZE_ARB-1:0] : msub_q[`DATA_SIZE_ARB-1:0];

	
	ModMult mult(.clk(clk),.reset(reset),
               .A(data_i),.B(twiddle_i),
               .q(q), .C(mult_out));
	
	shift_reg #(13, 12) delay_input(
	.clk(clk), .reset(reset),
	.data_i(data_i), .data_o(data_i_shifted)
);
					
	
	always_comb begin
		/*Mux one*/
		if (sel_a) 
			mux1_out = mult_out;
		else
			mux1_out = data_i_shifted;
			
		/*Mux two*/
		if (sel_b) 
			mux2_out = msub_res;		
		else
			mux2_out = even_out;
	end
	assign ntt_o = mux2_out;
	
	always_ff @(posedge clk) begin
		odd_out <= mux1_out;
		even_out <= madd_res;
	end


endmodule
			
	
	
