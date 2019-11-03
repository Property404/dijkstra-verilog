`include "constants.v"
module DistanceStore
#(parameter MAX_NODES=`DEFAULT_MAX_NODES,
parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH)
(
	input wire reset,
	input wire clock,
	// Are we getting or setting? Only one of these can be enabled at a time
	input wire get_en,
	input wire set_en,

	// The node we are accessing
	// This MUST be set on reset to indicate the source node
	input wire [INDEX_WIDTH-1:0] index,

	// The value to be assigned(if set_en)
	// or the value to be returned (if get_en)
	inout wire [VALUE_WIDTH-1:0] value
);

reg [MAX_NODES-1:0] dest_vector;

// Just a counting var for for-loops
integer i;

always @ (posedge clock) begin
	// All distances but source should start as INFINITY
	if(reset)
	begin
		for(i=0;i<MAX_NODES;i=i+1)
			dest_vector[i] = `INFINITY;
		dest_vector[index] = 0;
	end
end
endmodule
