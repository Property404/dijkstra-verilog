`include "constants.v"
`timescale 1ps/1ps

// Top level module for the HW implementation of Dijkstra's algorithm
module DijkstraTop
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH,
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH
)
(
	input wire reset,
	input wire clock,
	input wire[INDEX_WIDTH-1:0] number_of_nodes,
	input wire[MADDR_WIDTH-1:0] base_address,

	output wire mem_read_enable,
	output wire mem_write_enable,

	input wire mem_write_ready,
	input wire mem_read_ready,

	output wire [MADDR_WIDTH-1:0] mem_addr,
	input wire [MDATA_WIDTH-1:0] mem_read_data,
	output wire [MDATA_WIDTH-1:0] mem_write_data
);

reg pq_set_distance;
reg[INDEX_WIDTH-1:0] pq_index;
reg[VALUE_WIDTH-1:0] pq_distance_to_set;
wire[VALUE_WIDTH-1:0] pq_distance_read;
wire[INDEX_WIDTH-1:0] min_distance_node_index;
wire[VALUE_WIDTH-1:0] min_distance_node_value;

reg vs_set_prev_node;
reg[INDEX_WIDTH-1:0] vs_index;
reg[INDEX_WIDTH-1:0] vs_prev_node;
wire number_of_unvisited_nodes;

reg ec_query;
reg[INDEX_WIDTH-1] ec_from_node;
reg[INDEX_WIDTH-1] ec_to_node;
wire ec_ready;
wire [VALUE_WIDTH-1:0] ec_edge_value;


// Vector with paths of all nodes
wire [INDEX_WIDTH*MAX_NODES-1:0] prev_vector_flattened;
wire [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];
generate
	genvar j;
	for(j=0;j<MAX_NODES;j=j+1)
	begin
		assign prev_vector[j] = prev_vector_flattened[INDEX_WIDTH-1+INDEX_WIDTH*j:INDEX_WIDTH*j];
	end
endgenerate

VisitedStore #(.MAX_NODES(MAX_NODES), .INDEX_WIDTH(INDEX_WIDTH))
	visited_store (
		reset,
		clock,
		vs_set_prev_node,
		number_of_nodes,
		vs_index,
		vs_prev_node,
		number_of_unvisited_nodes,
		prev_vector_flattened
	);

PriorityQueue #(.MAX_NODES(MAX_NODES), .INDEX_WIDTH(INDEX_WIDTH), .VALUE_WIDTH(VALUE_WIDTH))
	priority_queue (
		reset,
		clock,
		pq_set_distance,
		pq_index,
		prev_vector_flattened,
		pq_distance_to_set,
		pq_distance_read,
		min_distance_node_index,
		min_distance_node_value
	);

EdgeCache
#(
	.MAX_NODES(MAX_NODES),
	.INDEX_WIDTH(INDEX_WIDTH),
	.VALUE_WIDTH(VALUE_WIDTH),
	.MADDR_WIDTH(MADDR_WIDTH),
	.MDATA_WIDTH(MDATA_WIDTH)
)
	edge_cache(
		reset,
		clock,
		base_address,
		number_of_nodes,
		ec_query,
		ec_from_node,
		ec_to_node,
		mem_addr,
		mem_data,
		mem_read_enable,
		mem_read_ready,
		ec_ready,
		ec_edge_value
	);

enum {MIDRESET_STATE, NEW_CURRENT_NODE_STATE}State 
State state;
State next_state;

always @(posedge clock)
begin
	if(reset)
	begin
		// All enables to zero
		pq_set_distance = 1'b0;
		vs_set_prev_node = 1'b0;
		ec_query = 1'b0;

		state = MIDRESET_STATE;
	end
	else
		state = next_state;
end

reg[INDEX_WIDTH-1:0] current_node;
always_comb
begin
	case(state)
		MIDRESET_STATE:
		begin
			next_state = SET_NEW_CURRENT_NODE_STATE;
		end
		NEW_CURRENT_NODE_STATE:
		begin
			current_node = min_distance_node_index;
			pq_index = current_node;
		end
	endcase
end



endmodule
