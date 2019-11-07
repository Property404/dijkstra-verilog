`include "constants.v"
`timescale 1ps/1ps

module BlockRamTestbench
#(
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH
)
(
);
	reg reset;
	reg clock;

	reg mem_read_enable = 0;
	reg mem_write_enable = 0;

	wire mem_write_ready;
	wire mem_read_ready;

	reg [MADDR_WIDTH-1:0] mem_addr;
	wire [MDATA_WIDTH-1:0] mem_data;

	reg[MDATA_WIDTH-1:0] write_data;
	assign mem_data = mem_write_enable?write_data:'bz;

	BlockRam br(
		reset,
		clock,
		mem_read_enable,
		mem_write_enable,
		mem_write_ready,
		mem_read_ready,
		mem_addr,
		mem_data
	);

	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	integer i;
	initial
		begin
		// First setup up to monitor all inputs and outputs
		//$monitor ("reset=%b,  set_en=%h, index=%d, value=%d, write_to_value=%d, mindex=%d, min_value=%d", reset,  set_en, index, value, write_to_value, min_index, min_value);

		// Reset 
		$display("~~~Starting BlockRam test~~~");
		clock = 0;
		reset = 1;
		@(posedge clock);
		@(posedge clock);
		reset = 0;
		@(posedge clock);
		@(posedge clock);
		$display("Reset complete");

		for(i=0;i<10;i=i+1)
		begin
			// Write to address
			@(posedge clock);
			write_data = i*i + 5;
			mem_addr = i*MADDR_WIDTH/8;
			mem_read_enable = 0;
			mem_write_enable = 1;

			// Wait until we wrote
			while(mem_write_ready == 0)
			begin
				@(posedge clock);
			end
			@(posedge clock);
			mem_write_enable = 0;

			// Confirm that we wrote correctly
			@(posedge clock);
			mem_read_enable = 1;
			// Wait until we read
			while(mem_read_ready == 0)
			begin
				@(posedge clock);
			end

			if(mem_data != write_data)
			begin
				$fatal(1, "memdata(%d)!=write_data(%d)", mem_data, write_data);
			end


			@(posedge clock);
			mem_read_enable = 0;

		end


		$display("Test completed successfully");
		$finish;


	end

endmodule //
