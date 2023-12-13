`include "defines.v"

module bit_reverse   (
	input clk, reset, valid,
   input [`DATA_SIZE_ARB-1:0]       din,
   output [`DATA_SIZE_ARB-1:0]      dout,
	output ram1_re, ram2_re, done,
	output [$clog2(`RING_SIZE)-1:0] addr
);

	logic [$clog2(`RING_SIZE)-1:0] temp_addr;
	logic temp_ram1, temp_ram2, temp_done;
	logic [$clog2(`RING_SIZE)-1:0] count = {$clog2(`RING_SIZE){1'b0}};
	logic [$clog2(`RING_SIZE)-1:0] index = {$clog2(`RING_SIZE){1'b0}};
	
	always_ff @(posedge clk) begin
		if (reset) begin
			count <= {$clog2(`RING_SIZE){1'b0}};
			temp_done = 1'b0;
		end
		else begin
			if (valid) begin
				count <= count + 1'b1;
			end
		end

		//All entries stored
		if (count >= `RING_SIZE - 1)
			temp_done = 1'b1;
	end
	
   	always_comb begin
		integer i;
		for(i = 0; i < $clog2(`RING_SIZE); i = i + 1) begin
			index[i] = count[$clog2(`RING_SIZE) - 1 - i];
		end

		if (valid)  begin
			if (index < (`RING_SIZE/2)) begin
				temp_ram1 = 1'b1;
				temp_ram2 = 1'b0;
				temp_addr = index;
			end
			else begin
				temp_ram1 = 1'b0;
				temp_ram2 = 1'b1;
				temp_addr = index - (`RING_SIZE/2);
			end
		end
		else begin
			temp_ram1 = 1'b0;
			temp_ram2 = 1'b0;
		end
	end
	
	
	assign dout = din;
	assign done = temp_done;
	assign addr = temp_addr;
	assign ram1_re = temp_ram1;
	assign ram2_re = temp_ram2;
	
	
endmodule