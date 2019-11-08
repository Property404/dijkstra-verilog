`include "constants.v"
`define SIZE_IN_WORDS (8*SIZE_IN_BYTES/MDATA_WIDTH)
module BlockRam
#(
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH,
	parameter SIZE_IN_BYTES=10*1024*1024
)
(
	input wire reset,
	input wire clock,

	input wire mem_read_enable,
	input wire mem_write_enable,

	output reg mem_write_ready,
	output reg mem_read_ready,

	input wire [MADDR_WIDTH-1:0] mem_addr,
	output reg [MDATA_WIDTH-1:0] mem_read_data,
	input wire [MDATA_WIDTH-1:0] mem_write_data
);
reg[MDATA_WIDTH-1:0] words[`SIZE_IN_WORDS-1:0];

// Pull down the enables if they're tristated
assign (pull1, pull0) mem_read_enable = 1'b0;
assign (pull1, pull0) mem_write_enable = 1'b0;


always @(posedge clock)
	begin
		// Reset ready signals
		mem_write_ready = 1'b0;
		mem_read_ready = 1'b0;

		// Store data
		if(mem_write_enable)
		begin
			words[8*mem_addr/MADDR_WIDTH] = mem_write_data;
			mem_write_ready = 1'b1;
		end

		// Send back data
		else if(mem_read_enable)
		begin
			mem_read_data = words[8*mem_addr/MADDR_WIDTH];
			mem_read_ready = 1'b1;
		end
	end
endmodule
