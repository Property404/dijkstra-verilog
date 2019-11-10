`include "constants.v"
`timescale 1ps/1ps
module VisitedStore
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH
)
(
	input wire reset,
	input wire clock,

	// Enable setting
	input wire set_en,

	// This should be set to the total number of nodes when reset is high. At
	// all other times, this is ignored
	input wire [INDEX_WIDTH-1:0] number_of_nodes,

	// The node we are accessing
	input wire [INDEX_WIDTH-1:0] index,

	// Previous node in path
	input wire [INDEX_WIDTH-1:0] prev_node,

	// Return number of nodes we have yet to visit
	output reg [INDEX_WIDTH-1:0] unvisited_nodes,

	output wire [INDEX_WIDTH*MAX_NODES-1:0] prev_vector_flattened
);

reg [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];

// Output a flattened version of prev_vector
generate
	genvar j;
	for(j=0;j<MAX_NODES;j=j+1)
	begin
		assign prev_vector_flattened[INDEX_WIDTH-1+INDEX_WIDTH*j:INDEX_WIDTH*j]
			= prev_vector[j];
	end
endgenerate

// Weakly pull down set_en
assign (weak1,weak0) set_en = 1'b0;

integer i;
always @ (posedge clock) begin
	// All distances but source should start as INFINITY
	if(reset)
	begin
		for(i=0;i<MAX_NODES;i=i+1)
			prev_vector[i] = `UNVISITED;
		unvisited_nodes = number_of_nodes;
	end

	// Set value
	if(set_en)
	begin
		if (prev_vector[index] == `UNVISITED)
		begin
			unvisited_nodes = unvisited_nodes - 1;
			prev_vector[index] = prev_node;
		end
	end
end
endmodule
