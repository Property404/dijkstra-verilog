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

reg stored_number_of_nodes;

reg pq_set_distance;
reg[INDEX_WIDTH-1:0] pq_index;
reg[VALUE_WIDTH-1:0] pq_distance_to_set;
wire[VALUE_WIDTH-1:0] pq_distance_read;
wire[INDEX_WIDTH-1:0] min_distance_node_index;
wire[VALUE_WIDTH-1:0] min_distance_node_value;

reg ec_query;
reg[INDEX_WIDTH-1:0] ec_from_node;
reg[INDEX_WIDTH-1:0] ec_to_node;
wire ec_ready;
wire [VALUE_WIDTH-1:0] ec_edge_value;

// Vector with paths of all nodes
reg [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];

// Visited nodes
integer number_of_unvisited_nodes;
reg [MAX_NODES-1:0] visited_vector;

PriorityQueue #(.MAX_NODES(MAX_NODES), .INDEX_WIDTH(INDEX_WIDTH), .VALUE_WIDTH(VALUE_WIDTH))
	priority_queue (
		reset,
		clock,
		pq_set_distance,
		pq_index,
		visited_vector,
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

typedef enum {V0, V1, V2, V3, V4, FINAL_STATE} State ;
State state;
State next_state;

integer i;
always @(posedge clock)
begin
	if(reset)
	begin
		// All enables to zero
		pq_set_distance = 1'b0;
		ec_query = 1'b0;

		// Set everything as unvisited
		stored_number_of_nodes = number_of_nodes;
		number_of_unvisited_nodes = number_of_nodes;
		for(i=0;i<MAX_NODES;i=i+1)
		begin
			visited_vector[i] = `UNVISITED;
			prev_vector[i] = `NO_PREVIOUS_NODE;
		end

		state = V0;
	end
	else
		state = next_state;
end

reg[INDEX_WIDTH-1:0] current_node;
reg[VALUE_WIDTH-1:0] current_node_value;
reg[VALUE_WIDTH-1:0] alt;
always_comb
begin
	case(state)
		V0:
		begin
			/* New node to be visited */

			current_node = min_distance_node_index;
			current_node_value = min_distance_node_value;
			number_of_unvisited_nodes = number_of_unvisited_nodes - 1;
			ec_query = 1;
			ec_from_node = current_node;
			ec_to_node = 0;
			pq_index = 0;
			if(number_of_unvisited_nodes >= 0)
				next_state = V1;
			else
				next_state = FINAL_STATE;
		end
		V1:
		begin
			// Mark as visited
			visited_vector[current_node] = current_node;
			next_state = V2;
		end
		V2:
		begin
			// Wait until we know the edge value
			if(ec_ready)
				next_state=V3;
		end
		V3:
		begin
			// Check if we need to reduce
			alt = current_node_value + ec_edge_value;
			if(alt < pq_distance_read)
			begin
				// Reduce
				prev_vector[pq_index] = current_node;
				pq_distance_to_set = alt;
				pq_set_distance = 1;
			end
			next_state = V4;
		end
		V4:
		begin
			pq_set_distance=0;
			pq_index = pq_index + 1;
			ec_to_node = ec_to_node + 1;

			if(pq_index >= number_of_nodes)
				next_state = V0;
			else
				next_state = V2;
		end
		FINAL_STATE:
		begin
			next_state = FINAL_STATE;
		end
	endcase
end



endmodule
