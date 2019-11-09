`include "constants.v"
`timescale 1ps/1ps
`define NUMBER_OF_NODES 14
`define BASE_ADDRESS 'h34

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
	wire [MDATA_WIDTH-1:0] mem_read_data;
	reg [MDATA_WIDTH-1:0] mem_write_data;
	wire mem_read_enable;
	wire mem_read_ready;
	reg mem_write_enable = 1'bz;
	wire mem_write_ready;

	reg read_from_testbench = 1'b0;
	assign mem_read_enable=read_from_testbench?1'b1:1'bz;

	// When we have the requested edge value, set ready high and edge_value to
	// the value from memory
	wire ready;
	wire [VALUE_WIDTH-1:0] edge_value;

	reg [MDATA_WIDTH-1:0] write_addr;
	reg [MDATA_WIDTH-1:0] read_addr;
	assign mem_addr= mem_write_enable?write_addr:
		read_from_testbench?read_addr:'bz;

	BlockRam bram(
		mem_reset,
		clock,
		mem_read_enable,
		mem_write_enable,
		mem_write_ready,
		mem_read_ready,
		mem_addr,
		mem_read_data,
		mem_write_data
	);

	EdgeCache edge_cache(
		reset,
		clock,
		base_address,
		number_of_nodes,
		query_enable,
		from_node,
		to_node,
		mem_addr,
		mem_read_data, 
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
				mem_write_data = row*column;
				if(mem_write_data !== row*column)
					$fatal(1, "you done goofed");
				write_addr = `BASE_ADDRESS+(row*`NUMBER_OF_NODES+column)*MADDR_WIDTH/8;
				mem_write_enable = 1;

				// Wait until we wrote
				while(mem_write_ready === 0)
				begin
					@(posedge clock);
				end
				if(mem_write_data !== row*column)
                    $fatal(1, "you done goofed");
				@(posedge clock);

				mem_write_enable = 1'bz;

				// Confirm we wrote correctly
				read_from_testbench = 1'b1;
				read_addr = write_addr;
				while(mem_read_ready === 0)
				begin
					@(posedge clock);
				end
				if(mem_read_data !== mem_write_data)
					$fatal(1, "Failed to write to Block Ram");
				@(posedge clock);
				read_from_testbench = 1'b0;

		
			end
		end

		@(posedge clock);
		$display("EdgeCache test now begins");
		@(posedge clock);

		// Reset EdgeCache
		mem_write_enable = 0;// Done writing
		reset = 0;
		query_enable = 0;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b1;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b0;

		// We're done with resetting, so these shouldn't matter
		base_address = 87; // bogus address
		number_of_nodes = 105; //bogus number of nodes

		$display("EdgeCache Reset complete");

		for(row=0;row<8;row=row+1)
			@(posedge clock);

		// Confirm we can sequentially access data
		for(row=0;row<`NUMBER_OF_NODES;row=row+1)
		begin
			from_node = row;
			for(column=0;column<`NUMBER_OF_NODES;column=column+1)
			begin
				@(posedge clock);
				to_node = column;
				query_enable = 1;
				$display("ROW, COLUMN=%d, %d", row, column);
				while(ready == 0)
				begin
					@(posedge clock);
				end
				$display("EDGE=%d", edge_value);
				if(edge_value !== row*column)
					$fatal(1, "edge_value(%d) != %d", edge_value, row*column);
				@(posedge clock);
				query_enable = 0;
				@(posedge clock);
			end
		end


		$display("Test completed successfully");
		$finish;


	end

endmodule //
