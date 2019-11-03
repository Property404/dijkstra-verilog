`include "constants.v"
`timescale 1ps/1ps

//module timeunit;
//        initial $timeformat(-9,1," ns",9);
//endmodule

// Here is the testbench proper:
module Testbench
#(parameter MAX_NODES=`DEFAULT_MAX_NODES,
parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH)
(
);
	reg reset;
	reg clock;
	reg get_en;
	reg set_en;
	reg [INDEX_WIDTH-1:0] index;
	wire [VALUE_WIDTH-1:0] value;

	DistanceStore dist_store(reset, clock, get_en, set_en, index, value);

	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	initial
		begin
		$timeformat(-12 ,0," ps",12);
		// First setup up to monitor all inputs and outputs
		$monitor ("reset=%b, get_en=%h, set_en=%h, index=%h, value=%h", reset, get_en, set_en, index, value);
		
		clock = 1'b0;
		reset = 1'b0;
		@(posedge clock); // 10 ns
		@(posedge clock); // 30 ns
		#42000;		// 72 ns
		reset = 1'b0;     // reset is inactive
		@(posedge clock); // 90 ns
		@(posedge clock); #2; // 112 ns
		$display("DONE");
	end

endmodule //
