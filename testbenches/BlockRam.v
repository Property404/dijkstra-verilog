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
	inout wire [MDATA_WIDTH-1:0] mem_data
);
reg[MDATA_WIDTH-1:0] output_data;
assign mem_data = mem_read_enable?output_data:'bz;

reg[MDATA_WIDTH-1:0] words[`SIZE_IN_WORDS-1:0];


always @(posedge clock)
	begin
		if(reset)
		begin
			mem_write_ready = 0;
			mem_read_ready = 0;
		end

		// Reset ready signals
		if(!mem_write_enable)
			mem_write_ready = 1'b0;
		if(!mem_read_enable)
			mem_read_ready = 1'b0;

		if(mem_write_enable)
		begin
			words[8*mem_addr/MADDR_WIDTH] = mem_data;
			mem_write_ready = 1'b1;
		end

		if(mem_read_enable)
		begin
			output_data = words[8*mem_addr/MADDR_WIDTH];
			mem_read_ready = 1'b1;
		end
	end
endmodule
