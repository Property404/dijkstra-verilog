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
	reg [INDEX_WIDTH-1:0] number_of_nodes=200;
	reg [INDEX_WIDTH-1:0] index;
	reg [INDEX_WIDTH-1:0] prev_node;
	wire [INDEX_WIDTH-1:0] unvisited_nodes;
	wire [INDEX_WIDTH*MAX_NODES-1:0] prev_vector_flattened;
	wire [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];

	generate
		genvar j;
		for(j=0;j<MAX_NODES;j=j+1)
			assign prev_vector[j] = prev_vector_flattened[INDEX_WIDTH-1+INDEX_WIDTH*j:INDEX_WIDTH*j];
	endgenerate

	VisitedStore vs
	(
		reset,
		clock,
		set_en,
		number_of_nodes,
		index,
		prev_node,
		unvisited_nodes,
		prev_vector_flattened
	);

	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	integer i;
	initial
	begin
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

		// Assert initial values are correct
		//

		$finish();

	end

endmodule //
