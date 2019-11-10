`include "constants.v"
`timescale 1ps/1ps


module PriorityQueueTestbench
#(
	parameter MAX_NODES= 8,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH
)
(
);
	integer i;
	reg reset=0;
	reg clock=0;
	reg set_en=0;
	reg [INDEX_WIDTH-1:0] index;
	wire [VALUE_WIDTH-1:0] value;
	reg [VALUE_WIDTH-1:0] write_to_value;
	wire[INDEX_WIDTH-1:0] min_index;
	wire[VALUE_WIDTH-1:0] min_value;
	wire [INDEX_WIDTH*MAX_NODES-1:0] prev_vector_flattened;
	reg [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];
	generate
		genvar j;
		for(j=0;j<MAX_NODES;j=j+1)
			assign  prev_vector_flattened
									[
										INDEX_WIDTH-1+INDEX_WIDTH*j:
										INDEX_WIDTH*j
									] = prev_vector[j];
	endgenerate


	PriorityQueue #(.MAX_NODES(MAX_NODES)) pq(reset, clock, set_en, index, prev_vector_flattened, value, min_index, min_value);

	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	// Allow us to write iff set_en is set
	assign value = set_en?write_to_value:{VALUE_WIDTH{1'bz}};

	integer min = `INFINITY;
	initial
		begin
		// Mark all as unvisited for test purposes
		for(i=0;i<MAX_NODES;i=i+1)
		begin
			prev_vector[i] = `UNVISITED;
		end
		// First setup up to monitor all inputs and outputs
		//$monitor ("reset=%b,  set_en=%h, index=%d, value=%d, write_to_value=%d, mindex=%d, min_value=%d", reset,  set_en, index, value, write_to_value, min_index, min_value);

		// Reset 
		reset = 0;
		set_en = 0;
		@(posedge clock);
		@(posedge clock);
		clock = 1'b0;
		reset = 1'b1;
		index = 1'b0;
		@(posedge clock);
		@(posedge clock);
		reset = 1'b0;
		$display("Reset complete");


		// Confirm we reset correctly
		@(posedge clock);
		@(posedge clock);
		if(value !== 0)
		begin
			$fatal(1, "Source should be 0");
		end
		for(index=1;index<MAX_NODES;index=index+1)
		begin
			@(posedge clock);
			@(posedge clock);
			if(value !== `INFINITY)
			begin
				$fatal(1, "dist[%d] = %d but should be infinity", index, value);
			end
		end

		if(min_value !== 0)
		begin
			$fatal(1,"Min value should initially be 0");
		end

		if(min_index !== 0)
		begin
			$fatal(1, "Min index should initially be 0");
		end

		$display("Initial values are correct");


		// Set source-to-source distance to infinity
		// So we can find the minimum value later
		// (because otherwise source will always be the minimum value, being
		// zero)
		@(posedge clock);#1;
		@(posedge clock);#1;
		set_en=1;
		write_to_value = `INFINITY;
		index = 0;
		@(posedge clock);#1;
		@(posedge clock);#1;
		set_en = 0;
		if(min_value !== `INFINITY)
		begin
			$fatal(1, "Min value should initially be infinity");
		end

		// Make sure we can read and write
		for(index=0;index<MAX_NODES;index=index+1)
		begin
			@(posedge clock);#1;
			@(posedge clock);#1;

			set_en = 1;
			write_to_value = $urandom % 50;
			if (min>write_to_value)
				min=write_to_value;

			@(posedge clock);#1;
			@(posedge clock);#1;
			set_en = 0;

			@(posedge clock);#1;
			@(posedge clock);#1;

			if(value !== write_to_value)
			begin
				$fatal(1, "FUCK");
			end

			if(min !== min_value)
			begin
				$fatal(1, "Minimum value is incorrect. Is %d, but should be %d", min_value, min);
			end
		end

		$display("Test completed successfully");
		$finish;


	end

endmodule //
