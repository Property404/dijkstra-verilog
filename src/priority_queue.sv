`include "constants.v"
`timescale 1ps/1ps

module PriorityQueue
#(parameter MAX_NODES=`DEFAULT_MAX_NODES,
parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH)
(
	input wire reset,
	input wire clock,

	// Are we getting or setting?
	input wire set_en,

	// The node we are accessing
	// This MUST be set on reset to indicate the source node
	input wire [INDEX_WIDTH-1:0] index,

	// Which nodes have been visited??
	input wire[MAX_NODES-1:0] visited_vector,

	// The value to be set (if set_en is high)
	input wire [VALUE_WIDTH-1:0] write_value,

	//the value to be returned (if set_en is low)
	output wire [VALUE_WIDTH-1:0] read_value,

	// Return highest priority node/distance
	output wire [INDEX_WIDTH-1:0] min_index,
	output wire [VALUE_WIDTH-1:0] min_value,
	output wire min_ready,

	output reg [VALUE_WIDTH-1:0] dist_vector[MAX_NODES-1:0]
);

// Just a counting var for for-loops
integer i;

// Output value if get_en is set
assign read_value = dist_vector[index];

MinHeap minheap(reset, clock, set_en, visited_vector, min_index, min_value, min_ready, dist_vector);

always @ (posedge clock) begin
	// All distances but source should start as INFINITY
	if(reset)
	begin
		for(i=0;i<MAX_NODES;i=i+1)
			dist_vector[i] = `INFINITY;
		dist_vector[index] = 0;
	end

	// Set value
	if(set_en)
		dist_vector[index] = write_value;
end
	
endmodule
