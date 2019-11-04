`include "constants.v"
`define LEVELS log2(MAX_NODES)

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

	// or the value to be returned (if get_en)
	inout wire [VALUE_WIDTH-1:0] value,

	// or the value to be returned (if get_en)
	output wire [INDEX_WIDTH-1:0] min_index,
	output wire [VALUE_WIDTH-1:0] min_value
);

reg [VALUE_WIDTH-1:0] dist_vector[MAX_NODES-1:0];


// Just a counting var for for-loops
integer i;

// Output value if get_en is set
assign value = set_en ? {VALUE_WIDTH{1'bz}}: dist_vector[index];

// Comb logic to get min
wire [INDEX_WIDTH-1:0] heap[2*MAX_NODES-2:0];
assign min_index = heap[2*MAX_NODES-2];
assign min_value = dist_vector[min_index];

// Find min index/value
`define ITEMS (2*MAX_NODES-start)/2
generate
	genvar j;
	for(j=0;j<MAX_NODES;j=j+1)
		assign heap[j] = j;
endgenerate
generate
	genvar start;
	for(start=0;start<2*MAX_NODES-2;start=(2*MAX_NODES+start)/2)
	begin
		genvar i;
		for(i=start;i<start+`ITEMS;i=i+2)
		begin
			assign heap[MAX_NODES+i/2] = dist_vector[heap[i]] < dist_vector[heap[i+1]]?heap[i]:heap[i+1];
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
		dist_vector[index] = value;
end
	
endmodule
