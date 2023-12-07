// simon32_64 testbench

`timescale 1ns/1ps

module ntt_tb();

// Modify params.vh based on Your design and point to Your local directory below
//`include "/classes/ece5746/projects/f23_final_project/params.vh" 
`include "C:/Users/oknat/Documents/Cornell_Tech/Reconfig_computing/parametric-ntt-master/defines.v"
  
  

reg clk, reset;
reg [`DATA_SIZE_ARB-1:0] q, MULin;
reg [`DATA_SIZE_ARB-1:0] NTTin0, NTTin1, twiddle, ntt_o;
reg [`DATA_SIZE_ARB-1:0] ADDout, SUBout;
reg [`DATA_SIZE_ARB-1:0] NTToutEVEN, NTToutODD;

reg [`DATA_SIZE_ARB-1:0] din, dout;
logic [$clog2(`RING_SIZE)-1:0] addr;
logic start, valid, ram1_re, ram2_re, done;


integer fh_in, fh_out, index;

NTT2 dut(	.clk(clk),.reset(reset),
			.q(q),
			.NTTin0(NTTin0),.NTTin1(NTTin1),
			.MULin(MULin),
			.ADDout(ADDout),.SUBout(SUBout),
			.NTToutEVEN(NTToutEVEN),.NTToutODD(NTToutODD));

			
bit_reverse bit_rev(
	.clk(clk), .reset(reset), .valid(valid),
   .din(NTTin0),
   .dout(dout),
	.ram1_re(ram1_re), .ram2_re(ram2_re), .done(done),
	.addr(addr)
);


PE Pe1(.clk(clk), .reset(reset),
	.q(q), .data_i(NTTin0), .start(start),
	.twiddle_i(twiddle), .ntt_o(ntt_o)
);
  
 
initial begin
  fh_in  = $fopen("/Users/oknat/Documents/Cornell_Tech/new_test/inputs.txt", "r");
  //fh_out = $fopen("simon32_64.outputs","w");
end

assign q = 13'h1e01;
//assign NTTin0 = 13'hcf1;
assign NTTin1 = 13'h454;
assign MULin  = 13'h3de;

// Set intial values and reset the module
initial begin
	clk = 0;
	index = 0;
	reset = 1'b1;
	#22 reset = 1'b0;
	/*
	NTTin0 = 12'h001;
	twiddle = 12'h002;

	#40 NTTin0 = 12'h002;
	twiddle = 12'h003;

	#40 NTTin0 = 12'h003;
	twiddle = 12'h004;
	

	#10 din = 13'h1000;
	#10 din = 13'h0001;
	#10 din = 13'h1fbf;
	*/
end

// skip invalid cycles and start writing outputs
// assumes input and outputs are flopped
/*always @(negedge clk_tb) begin
	if(index > (2+NumStages)) begin
		$fwrite(fh_out,"%h\n", ciphertext);
	end
end*/
  
// toggle clk at ClkPeriod/2
always #(2) clk = ~clk;


always @(posedge clk) begin
	if (reset == 1'b0) begin
		valid <= 1'b1;
		$fscanf(fh_in,"%h \n",NTTin0);
    	
      	index <= index+1;
        
    	// ### Added Numstages for the pipelined design ###
      	if ($feof(fh_in)) begin
        	//$fclose(fh_out);
            $fclose(fh_in);
            //$finish;
			valid = 1'b0;
        end  
	end
end

assign twiddle = NTTin0;

always #100 $finish;

 

//##### For generating .vcd.gz for primetime ##########
initial
   begin
     $dumpfile("ntt.vcd.gz");
     $dumpvars(0,ntt_tb);
   end

endmodule


