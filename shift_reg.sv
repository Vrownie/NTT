//Shift Register to pass valid signal

module shift_reg #
(
	parameter WIDTH = 16,
	parameter STAGES = 0
)
(
	input clk, reset,
	input [WIDTH-1:0] data_i,
	output [WIDTH-1:0] data_o
);

logic [WIDTH-1:0] temp_output [STAGES-1:0];

always_ff @(posedge clk) begin
	if (reset) 
		temp_output[0] <= 0;
	else 
		temp_output[0] <= data_i;		
end

genvar i;
generate
	for(i = 0; i < STAGES - 1; i = i + 1) begin: Shift
		always_ff @ (posedge clk) begin
			if (reset)
				temp_output[i+1] <= 0;
			else
				temp_output[i+1] <= temp_output[i];
		end
	end
endgenerate

assign data_o = temp_output[STAGES-1];

endmodule
