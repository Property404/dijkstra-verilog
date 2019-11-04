`include "constants.v"
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

	input wire [INDEX_WIDTH-1:0] number_of_nodes,

	// The node we are accessing
	input wire [INDEX_WIDTH-1:0] index,

	// Previous node in path
	input wire [INDEX_WIDTH-1:0] prev_node,

	// return 1 if all nodes have been visited
	output reg [INDEX_WIDTH-1:0] unvisited_nodes,

	//output wire [INDEX_WIDTH*MAX_NODES-1:0] prev_vector
	output reg [INDEX_WIDTH-1:0] prev_vector_reg[MAX_NODES-1:0]

);

integer i;
always @ (posedge clock) begin
	// All distances but source should start as INFINITY
	if(reset)
	begin
		for(i=0;i<MAX_NODES;i=i+1)
			prev_vector_reg[i] = `UNVISITED;
		unvisited_nodes = number_of_nodes;
	end

	// Set value
	if(set_en)
	begin
		if (prev_vector_reg[index] == `UNVISITED)
		begin
			unvisited_nodes = unvisited_nodes - 1;
			prev_vector_reg[index] = prev_node;
		end
	end
end
endmodule
