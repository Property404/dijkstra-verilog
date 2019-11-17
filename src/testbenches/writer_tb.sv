`include "constants.v"
`define NUM_NODES 8
`define STARTING_ADDRESS 0

module WriterTestbench
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH,
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH
);

reg reset = 0;
reg clock = 0;
reg enable = 0;

reg [MADDR_WIDTH-1:0] starting_address = `STARTING_ADDRESS;
reg [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0];
reg [INDEX_WIDTH-1:0] number_of_nodes = `NUM_NODES;

wire mem_write_enable;
wire mem_write_ready;
reg mem_read_enable = 0;
wire mem_read_ready;
wire [MADDR_WIDTH-1:0] mem_addr;
wire [MDATA_WIDTH-1:0] mem_write_data;
wire [MDATA_WIDTH-1:0] mem_read_data;

wire ready;

reg [MADDR_WIDTH-1:0] tb_mem_addr;
assign mem_addr = mem_read_enable?tb_mem_addr:'z;

Writer writer
(
	reset, clock, enable,
	starting_address,
	prev_vector,
	number_of_nodes,
	mem_write_enable,
	mem_write_ready,
	mem_addr,
	mem_write_data,
	ready
);

BlockRam block_ram
(
	reset, clock,
	mem_read_enable,
	mem_write_enable,
	mem_write_ready,
	mem_read_ready,
	mem_addr,
	mem_read_data,
	mem_write_data
);

// Setup clock to automatically strobe with a period of 20.
always #10000 clock = ~clock;

integer i;
initial
begin
	// Fill prev_vector
	for(i=0;i<`NUM_NODES;i=i+1)
	begin
		prev_vector[i] = $urandom() % (2**INDEX_WIDTH - 1);
	end

	// Reset
	@(posedge clock);
	reset = 1;
	@(posedge clock)
	reset = 0;
	enable = 1;
	@(posedge clock)

	while(ready == 0)
		@(posedge clock);

	// Confirm all is good
	for(i=0;i<`NUM_NODES;i=i+1)
	begin
		@(posedge clock);
		tb_mem_addr = `STARTING_ADDRESS + i * MADDR_WIDTH/8;
		mem_read_enable = 1;
		
		while(mem_read_ready === 0)
			@(posedge clock);

   
            
		if(mem_read_data !== prev_vector[i])
			$fatal(1, "%x !== %x", mem_read_data, prev_vector[i]);
		
		@(posedge clock);
		mem_read_enable = 0;
		while(mem_read_ready !== 0)
            @(posedge clock);
	end

	$finish();
end
endmodule
