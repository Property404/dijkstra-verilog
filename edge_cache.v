`include "constants.v"
`timescale 1ps/1ps

// Directly polls memory for edges
// and hands out values
module EdgeCache
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

	// Initial values
	input wire[MADDR_WIDTH-1:0] base_address,
	input wire[INDEX_WIDTH-1:0] number_of_nodes,

	// Input signals for when we want to query an edge
	input wire query_enable,
	input wire[INDEX_WIDTH-1:0] from_node,//row
	input wire[INDEX_WIDTH-1:0] to_node,//column

	// Memory interface
	output reg [MADDR_WIDTH-1:0] mem_addr,
	input wire [MDATA_WIDTH-1:0] mem_data,
	output reg mem_read_enable,
	input wire mem_read_ready,

	// When we have the requested edge value, set ready high and edge_value to
	// the value from memory
	output reg ready,
	output reg [VALUE_WIDTH-1:0] edge_value
);

// Becomes high on a reset or when row cache is emptied
// Becomes low when row_cache is filled
// Semantically means that the row_cache is not yet filled
reg row_incomplete;

// These represent the cell we're currently filling
integer column;
integer row;

// Store initial values
reg [MADDR_WIDTH-1:0] stored_base_address;
reg [INDEX_WIDTH-1:0] stored_number_of_nodes;

// Where the row is stored after we pull it from the graph
reg [VALUE_WIDTH-1:0] row_cache[MAX_NODES-1:0];

// High if we're waiting for a response from RAM
reg waiting_for_memory;


always @(posedge clock)
begin
	// Release memory lines so other components can access memory
	mem_addr = 'bz;
	mem_read_enable = 1'bz;

	if(reset)
	begin
		row_incomplete = 1'b1;
		column = 0;
		row = 0;
		stored_base_address = base_address;
		stored_number_of_nodes = number_of_nodes;
		ready = 1'b0;
		waiting_for_memory = 1'b0;
	end

	// Fill row_cache
	if(row_incomplete && !waiting_for_memory)
	begin
		// Request to read particular cell
		mem_addr = stored_base_address + row*(MADDR_WIDTH/8)*stored_number_of_nodes + column*MADDR_WIDTH/8;
		mem_read_enable = 1'b1;
		waiting_for_memory = 1'b1;
	end
	if(waiting_for_memory && mem_read_ready)
	begin

		waiting_for_memory = 1'b0;

		// Store cell in row cache
		row_cache[column] = mem_data;
		column = column + 1;

		// Have we filled the row yet?
		if(column >= stored_number_of_nodes)
			row_incomplete = 1'b0;
	end

	// Respond to client's request for data
	ready=0;
	edge_value = 'bz;
	if(query_enable && !row_incomplete)
	begin
		// TODO: dump when end is reached
		if(from_node == row && column > to_node)
		begin
			edge_value = row_cache[to_node];
			ready = 1;
		end
		else if(from_node != row && !row_incomplete) 
		begin
			// We don't have the data. Dump and fill 
			row = from_node;
			column = 0;
			row_incomplete = 1'b1;
		end
	end
end
	
endmodule
