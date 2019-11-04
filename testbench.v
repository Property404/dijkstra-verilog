`include "constants.v"
`timescale 1ps/1ps

module Testbench
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH
)
(
);
	reg reset=0;
	reg clock=0;
	reg set_en=0;
	reg [INDEX_WIDTH-1:0] index;
	wire [VALUE_WIDTH-1:0] value;
	reg [VALUE_WIDTH-1:0] write_to_value;
	wire[INDEX_WIDTH-1:0] min_index;
	wire[VALUE_WIDTH-1:0] min_value;

	PriorityQueue dist_store(reset, clock, set_en, index, value, min_index, min_value);

	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;
	integer i;

	assign value = set_en?write_to_value:{VALUE_WIDTH{1'bz}};

	initial
		begin
		$timeformat(-12 ,0," ps",12);
		// First setup up to monitor all inputs and outputs
		//$monitor ("reset=%b,  set_en=%h, index=%d, value=%d, write_to_value=%d, mindex=%d, min_value=%d", reset,  set_en, index, value, write_to_value, min_index, min_value);

		// Reset 
		reset = 0;
		set_en = 0;
		@(posedge clock);
		@(posedge clock);
		clock = 1'b0;
		reset = 1'b1;
		index = 1'b0;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b0;
		$display("Reset complete");


		// Confirm we reset correctly
		@(posedge clock);
		@(posedge clock);
		if(value != 0)
		begin
			$display("Source should be 0");
			$finish();
		end
		for(index=1;index<MAX_NODES;index++)
		begin
			@(posedge clock);
			@(posedge clock);
			if(value != `INFINITY)
			begin
				$display("dist[%d] = %d but should be infinity", index, value);
				$finish();
			end
		end
		$display("Initial values are correct");
			@(posedge clock);#1;
			@(posedge clock);#1;
			set_en=1;
			write_to_value = 200;
			index = 0;


			@(posedge clock);#1;
			@(posedge clock);#1;
			set_en = 0;
		
		for(i=0;i<10;i++)
		begin
			@(posedge clock);#1;
			@(posedge clock);#1;

			set_en = 1;
			index = $urandom % 50;
			write_to_value = $urandom % 50;

			@(posedge clock);#1;
			@(posedge clock);#1;
			set_en = 0;

			@(posedge clock);#1;
			@(posedge clock);#1;

			if(value != write_to_value)
			begin
				$display("FUCK");
				$finish();
			end

		end

		$display("Test completed successfully");
		$finish;


	end

endmodule //
