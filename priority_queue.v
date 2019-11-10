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

	// Flattened vector of each index's previous node
	// That is, it shows the paths. More importantly,
	// it show which nodes have been visited and which nodes haven't
	input wire[INDEX_WIDTH*MAX_NODES-1:0] prev_vector_flattened,

	// The value to be set (if set_en is high)
	input wire [VALUE_WIDTH-1:0] write_value,

	//the value to be returned (if set_en is low)
	output wire [VALUE_WIDTH-1:0] read_value,

	// Return highest priority node/distance
	output wire [INDEX_WIDTH-1:0] min_index,
	output wire [VALUE_WIDTH-1:0] min_value
);

reg [VALUE_WIDTH-1:0] dist_vector[MAX_NODES-1:0];

// Weakly pull down set_en
assign (weak1,weak0) set_en = 1'b0;

// Just a counting var for for-loops
integer i;

// Output value if get_en is set
assign read_value = dist_vector[index];

// Unflattened version of the aforementioned prev vector
wire [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];
generate
	genvar j;
	for(j=0;j<MAX_NODES;j=j+1)
		assign prev_vector[j] = prev_vector_flattened
								[
									INDEX_WIDTH-1+INDEX_WIDTH*j:
									INDEX_WIDTH*j
								];
endgenerate


// Comb logic to get min
wire [INDEX_WIDTH-1:0] heap[2*MAX_NODES-2:0];
assign min_index = heap[2*MAX_NODES-2];
assign min_value = dist_vector[min_index];

// Find min index/value
`define ITEMS (2*MAX_NODES-start)/2
generate
	genvar k; for(k=0;k<MAX_NODES;k=k+1)
		assign heap[k] = k;
endgenerate
generate
	genvar start;
	for(start=0;start<2*MAX_NODES-2;start=(2*MAX_NODES+start)/2)
	begin
		genvar i;
		for(i=start;i<start+`ITEMS;i=i+2)
		begin
			assign heap[MAX_NODES+i/2] =
				prev_vector[heap[i]] != `UNVISITED?
					heap[i+1]:
					prev_vector[heap[i+1]] != `UNVISITED?
						heap[i]:
						dist_vector[heap[i]] < dist_vector[heap[i+1]]?
							heap[i]:
							heap[i+1];
		end
	end
endgenerate


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
