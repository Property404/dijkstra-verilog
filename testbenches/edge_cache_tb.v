`include "constants.v"
`timescale 1ps/1ps

module EdgeCacheTestbench
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH
)
(
);
	reg reset=0;
	reg clock=0;

	// Initial values
	reg [MADDR_WIDTH-1:0] base_address;
	reg [INDEX_WIDTH-1:0] number_of_nodes;

	// Input signals for when we want to query an edge
	reg query_enable;
	reg [INDEX_WIDTH-1:0] from_node;
	reg [INDEX_WIDTH-1:0] to_node;

	// Memory interface
	wire [MADDR_WIDTH-1:0] mem_addr;
	wire [MDATA_WIDTH-1:0] mem_data;
	wire mem_read_enable;
	wire mem_read_ready;

	// When we have the requested edge value, set ready high and edge_value to
	// the value from memory
	wire ready;
	wire [VALUE_WIDTH-1:0] edge_value;

	EdgeCache ec(
		reset,
		clock,
		base_address,
		number_of_nodes,
		from_node,
		to_node,
		mem_addr,
		mem_data, 
		mem_read_enable,
		mem_ready_ready,
		ready,
		edge_value
	);
	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	initial
		begin
		// First setup up to monitor all inputs and outputs
		//$monitor ("reset=%b,  set_en=%h, index=%d, value=%d, write_to_value=%d, mindex=%d, min_value=%d", reset,  set_en, index, value, write_to_value, min_index, min_value);

		// Reset 
		reset = 0;
		base_address = 0;
		number_of_nodes = 10;
		@(posedge clock);
		@(posedge clock);
		clock = 1'b0;
		reset = 1'b1;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b0;

		$display("Reset complete");


		$display("Test completed successfully");
		$finish;


	end

endmodule //
