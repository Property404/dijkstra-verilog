`include "constants.v"
`timescale 1ps/1ps

`define BASE_ADDRESS 0
`define NUMBER_OF_NODES 8
`define TEST_VECTOR_FILE "testvectors/testvectors.txt"

function string get_tv_path();
    int i;
    int str_index;
    logic found_path;
    string fullpath_filename = `__FILE__;
    string test_vector_file = `TEST_VECTOR_FILE;
    automatic string ret="";


	$display("~~~~~~~~~~~~~~~~~~~~~~~~");
	$display("%s", fullpath_filename);
    for (i = fullpath_filename.len()-1; i>0; i=i-1) begin
        if (fullpath_filename[i] == "/" || fullpath_filename[i] == "\\")
        begin
            found_path=1;
            str_index=i;
            break;
        end
    end
    if (found_path===1) begin
        ret=fullpath_filename.substr(0,str_index);
    end else begin
       	$fatal("Bleeaaargh");
    end
        

    return {ret, test_vector_file};
endfunction

module DijkstraTopTestbench
#(
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH,
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH
)
(
);
	reg reset = 0;
	reg clock = 0;

	reg enable = 0;
	
	wire ready;

	reg [INDEX_WIDTH-1:0] number_of_nodes = `NUMBER_OF_NODES;
	reg [MADDR_WIDTH-1:0] base_address = `BASE_ADDRESS;

	reg [INDEX_WIDTH-1:0] source = 0;
	reg [INDEX_WIDTH-1:0] destination = `NUMBER_OF_NODES - 1;

	wire mem_read_enable;
	wire mem_write_enable;

	wire mem_write_ready;
	wire mem_read_ready;

	wire [MADDR_WIDTH-1:0] mem_addr;

	wire [MDATA_WIDTH-1:0] mem_write_data;
	wire [MDATA_WIDTH-1:0] mem_read_data;

	reg do_write=0;
	reg do_read=0;
	reg [MDATA_WIDTH-1:0] tb_write_data;
	reg [MADDR_WIDTH-1:0] tb_addr;

	assign mem_read_enable=do_read?1'b1:1'bz;

	assign mem_write_enable=do_write?1'b1:1'bz;
	assign mem_write_data=do_write?tb_write_data:'bz;

	assign mem_addr=(do_write || do_read)?tb_addr:'bz;

	BlockRam br(
		reset,
		clock,
		mem_read_enable,
		mem_write_enable,
		mem_write_ready,
		mem_read_ready,
		mem_addr,
		mem_read_data,
		mem_write_data
	);

	DijkstraTop dijkstra(
		reset,
		clock,
		enable,
		source,
		destination,
		number_of_nodes,
		base_address,
		mem_read_enable,
		mem_write_enable,
		mem_write_ready,
		mem_read_ready,
		mem_addr,
		mem_read_data,
		mem_write_data,
		ready
	);

	reg [VALUE_WIDTH-1:0] graph[(MAX_NODES**2)-1:0];


	// Setup clock to automatically strobe with a period of 20.
	always #10000 clock = ~clock;

	integer row;
	integer column;
	integer i;
	integer j;
	integer num_test_cases;
	integer seed;
	integer testvectors;

	reg[INDEX_WIDTH-1:0] prev;

	initial
	begin


		// Load test vectors
		testvectors = $fopen(get_tv_path(), "r");
		if(testvectors == 0)
			$fatal(1, "Couldn't load test vectors");
		$fscanf(testvectors, "%d", num_test_cases);

		for(i=0;i<num_test_cases;i=i+1)
		begin
			$fscanf(testvectors, "%d", number_of_nodes);
			$fscanf(testvectors, "%d", seed);
			@(posedge clock);
			@(posedge clock);

			// Create graph
			`define POS (row*number_of_nodes + column)
			`define TPOS (column*number_of_nodes + row)
			for(row=0;row<number_of_nodes;row=row+1)
				for(column=0;column<number_of_nodes;column=column+1)
				begin

					// Load edge value into graph
					$fscanf(testvectors, "%d", tb_write_data);
					graph[`POS] = tb_write_data;

					// Assert we recorded the edge value
					if(graph[`POS] !== tb_write_data)
						$fatal(1, "Edge value not recorded");

					// Write to memory
					do_write = 1;
					tb_addr = base_address + `POS * MADDR_WIDTH/8;
					while(mem_write_ready == 0)
						@(posedge clock);
					@(posedge clock);
					do_write = 0;
					@(posedge clock);

					// Make sure we wrote correctly
					do_read = 1;
					while(mem_read_ready == 0)
						@(posedge clock);
					if(mem_read_data !== graph[`POS])
						$fatal(1, "Did not write edge value to memory");
					@(posedge clock);
					do_read = 0;
				end

			// Print graph
			$display("~~~GRAPH~~~");
			for(row=0;row<number_of_nodes;row=row+1)
			begin
				for(column=0;column<number_of_nodes;column=column+1)
				begin
					$write("%d ", graph[`POS]);
				end
				$display("\n");
			end

		
			// Reset and enable
			reset = 0;
			enable = 1;
			@(posedge clock);
			reset = 1;
			@(posedge clock);
			reset = 0;

			while(ready !== 1)
			begin
				@(posedge clock);
			end
			@(posedge clock);

			
			// Confirm we've written correctly
			$display("Prev:");
			for(j=0;j<number_of_nodes;j++)
			begin
				tb_addr = `BASE_ADDRESS + (number_of_nodes**2+j) * (MADDR_WIDTH/8);
				do_read = 1;
				@(posedge clock);
				while(mem_read_ready !== 1)
				begin
					@(posedge clock);
				end
				@(posedge clock);
				$fscanf(testvectors, "%d", prev);
				$write("0x%x ", prev);
				if(mem_read_data !== prev)
				    $fatal(1, "%d !== %d", mem_read_data, prev);
				@(posedge clock);
				do_read = 0;
				@(posedge clock);
			end
			$display("");
		end

		$display("Top Test completed successfully");
		$fclose(testvectors);
		$finish;


	end

endmodule
