`include "constants.v"

module Writer
#(
	parameter MAX_NODES=`DEFAULT_MAX_NODES,
	parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
	parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH,
	parameter MADDR_WIDTH=`DEFAULT_MADDR_WIDTH,
	parameter MDATA_WIDTH=`DEFAULT_MDATA_WIDTH
)
(
	input reset,
	input clock,
	input enable,

	input wire [MADDR_WIDTH-1:0] starting_address,
	input wire [INDEX_WIDTH-1:0] prev_vector[MAX_NODES-1:0],
	input wire [INDEX_WIDTH-1:0] number_of_nodes,

	output reg mem_write_enable,

	input wire mem_write_ready,

	output reg [MADDR_WIDTH-1:0] mem_addr,
	output reg [MDATA_WIDTH-1:0] mem_write_data,

	output reg ready
);

reg[MADDR_WIDTH-1:0] addr;

typedef enum {BEGIN, S0, S1, S2, FINAL} State;
State state;
State next_state;

integer index;

always @(posedge clock)
begin
	if(reset || !enable)
	begin
		mem_write_enable = 'z;
		mem_write_data = 'z;
		mem_addr = 'z;
		addr = starting_address;
		state = BEGIN;
		index = 0;
		ready = 0;
		next_state = BEGIN;
	end

	else if(enable)
	begin
		mem_addr = addr;

		case(state)
			BEGIN:
			begin
				if(enable)
					next_state = S0;
			end

			S0:
			begin
				mem_write_enable = 1;

				mem_write_data = prev_vector[index];
				addr = starting_address + index*MADDR_WIDTH/8;

				index += 1;
				next_state = S1;
			end
			S1:
			begin
				if(mem_write_ready)
				begin
					mem_write_enable = 0;
					if(index > number_of_nodes)
						next_state = FINAL;
					else
						next_state = S2;
				end
			end
			S2:
			begin
				if(!mem_write_ready)
					next_state = S0;
			end
			FINAL:
			begin
				mem_write_enable = 'z;
				mem_write_data = 'z;
				mem_addr = 'z;
				ready = 1;
			end
		endcase

		state = next_state;
	end
end

endmodule
