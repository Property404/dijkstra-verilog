`include "constants.v"
`timescale 1ps/1ps
module DistanceStore
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

	// or the value to be returned (if get_en)
	inout wire [VALUE_WIDTH-1:0] value
);

reg [VALUE_WIDTH-1:0] dist_vector[MAX_NODES-1:0];

// Just a counting var for for-loops
integer i;

// Output value if get_en is set
assign value = set_en ? {VALUE_WIDTH{1'bz}}: dist_vector[index];

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
		dist_vector[index] = value;
end
endmodule
