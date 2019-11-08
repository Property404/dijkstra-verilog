`include "constants.v"
`timescale 1ps/1ps
`define NUMBER_OF_NODES 4
`define BASE_ADDRESS 64

module EdgeCacheTestbench
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH,
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH
)
(
);
	reg mem_reset=0;
	reg reset=0;
	reg clock=0;

	// Initial values
	reg [MADDR_WIDTH-1:0] base_address = `BASE_ADDRESS;
	reg [INDEX_WIDTH-1:0] number_of_nodes = `NUMBER_OF_NODES;

	// Input signals for when we want to query an edge
	reg query_enable;
	reg [INDEX_WIDTH-1:0] from_node;
	reg [INDEX_WIDTH-1:0] to_node;

	// Memory interface
	wire [MADDR_WIDTH-1:0] mem_addr;
	wire [MDATA_WIDTH-1:0] mem_data;
	wire mem_read_enable;
	wire mem_read_ready;
	reg mem_write_enable;
	wire mem_write_ready;

	// When we have the requested edge value, set ready high and edge_value to
	// the value from memory
	wire ready;
	wire [VALUE_WIDTH-1:0] edge_value;

	reg [MDATA_WIDTH-1:0] write_data;
	assign mem_data = mem_write_enable?write_data:'bz;

	reg [MDATA_WIDTH-1:0] write_addr;
	assign mem_addr= mem_write_enable?write_addr:'bz;

	BlockRam br(
		mem_reset,
		clock,
		mem_read_enable,
		mem_write_enable,
		mem_write_ready,
		mem_read_ready,
		mem_addr,
		mem_data
	);

	EdgeCache ec(
		reset,
		clock,
		base_address,
		number_of_nodes,
		query_enable,
		from_node,
		to_node,
		mem_addr,
		mem_data, 
		mem_read_enable,
		mem_read_ready,
		ready,
		edge_value
	);
	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	integer row=0;
	integer column=0;
	initial
		begin
		// Reset memory
		mem_reset = 0;
		@(posedge clock);
		@(posedge clock);
		mem_reset = 1;
		@(posedge clock);
		@(posedge clock);
		mem_reset = 0;

		// Set memory
		for(row=0;row<`NUMBER_OF_NODES;row=row+1)
		begin
			for(column=0;column<`NUMBER_OF_NODES;column=column+1)
			begin
				// Write to address
				@(posedge clock);
				write_data = row*column;
				write_addr = `BASE_ADDRESS+(row*`NUMBER_OF_NODES+column)*MADDR_WIDTH/8;
				mem_write_enable = 1;

				// Wait until we wrote
				while(mem_write_ready === 0)
				begin
					@(posedge clock);
				end
				@(posedge clock);
				mem_write_enable = 0;
			end
		end

		// Reset EdgeCache
		reset = 0;
		query_enable = 0;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b1;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b0;
		base_address = 87; // bogus address
		number_of_nodes = 105; //bogus number of nodes

		$display("Reset complete");

		// Confirm we can sequentially access data
		for(row=0;row<`NUMBER_OF_NODES;row=row+1)
		begin
			from_node = row;
			for(column=0;column<`NUMBER_OF_NODES;column=column+1)
			begin
				to_node = column;
				query_enable = 1;
				while(ready == 0)
				begin
					@(posedge clock);
				end
				if(edge_value !== row*column)
					$fatal(1, "edge_value(%d) != %d", edge_value, row*column);
				@(posedge clock);
				@(posedge clock);
			end
		end


		$display("Test completed successfully");
		$finish;


	end

endmodule //
