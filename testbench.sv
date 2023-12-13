// simon32_64 testbench

`timescale 1ns/1ps

module ntt_tb();

// Modify params.vh based on Your design and point to Your local directory below
//`include "/classes/ece5746/projects/f23_final_project/params.vh" 
//`include "C:/Users/oknat/Documents/Cornell_Tech/new_test/inputs.txt"
`include "defines.v"


reg clk, reset;
reg [`DATA_SIZE_ARB-1:0] q, MULin;
reg [`DATA_SIZE_ARB-1:0] NTTin0, NTTin1, twiddle, ntt_o;
reg [`DATA_SIZE_ARB-1:0] ADDout, SUBout;
reg [`DATA_SIZE_ARB-1:0] NTToutEVEN, NTToutODD;

reg [`DATA_SIZE_ARB-1:0] din, dout;
logic [$clog2(`RING_SIZE)-1:0] addr;
logic start, valid, ram1_re, ram2_re;
logic sel_a, sel_b;
logic [11:0] stage;

integer fh_in, fh_out, index, tw_in;
			
bit_reverse bit_rev(
	.clk(clk), .reset(reset), .valid(valid),
	.din(NTTin0),
	.dout(dout),
	.ram1_re(ram1_re), .ram2_re(ram2_re), .done(start),
	.addr(addr)
);

contoller control_unit( 
    .clk(clk), .reset(reset),
    .start(start),
    .sel_a(sel_a), .sel_b(sel_b), .sel_ram(sel_ram),
    .stage(stage)
);

PE Pe1(.clk(clk), .reset(reset),
	.start(start), .sel_a(sel_a), .sel_b(sel_b),
	.q(q), .data_i(NTTin0),
	.twiddle_i(twiddle), .ntt_o(ntt_o)
);
  
 
initial begin
  fh_in  = $fopen("C:/Users/oknat/Documents/Cornell_Tech/Reconfig_computing/project/NTT/NTT_DIN.txt", "r");
  tw_in = $fopen("C:/Users/oknat/Documents/Cornell_Tech/Reconfig_computing/project/NTT/W.txt", "r");
end

assign q = 13'h12c1;
//assign NTTin0 = 13'hcf1;
assign NTTin1 = 13'h454;
assign MULin  = 13'h3de;

// Set intial values and reset the module
initial begin
	clk = 0;
	index = 0;
	reset = 1'b1;
	#22 reset = 1'b0;
end

  
// toggle clk at ClkPeriod/2
always #(2) clk = ~clk;


always @(posedge clk) begin
	if (reset == 1'b0) begin
		valid <= 1'b1;
		if (start == 1'b1) begin
			$fscanf(fh_in,"%d \n",NTTin0);
			$fscanf(tw_in,"%d \n",twiddle);
		end
    	
      	index <= index+1;
        
    	// ### Added Numstages for the pipelined design ###
      	if ($feof(fh_in)) begin
        	//$fclose(fh_out);
            $fclose(fh_in);
            $fclose(tw_in);
            //$finish;
        end  
	end
end

always #1200 $finish;

 

//##### For generating .vcd.gz for primetime ##########
initial
   begin
     $dumpfile("ntt.vcd.gz");
     $dumpvars(0,ntt_tb);
   end

endmodule


