`include "constants.v"
`timescale 1ps/1ps

module MinHeap
#(parameter MAX_NODES=`DEFAULT_MAX_NODES,
parameter INDEX_WIDTH=`DEFAULT_INDEX_WIDTH,
parameter VALUE_WIDTH=`DEFAULT_VALUE_WIDTH)
(
	input wire reset,
	input wire clock,

	input wire set_en,

	// Which nodes have been visited??
	input wire[MAX_NODES-1:0] visited_vector,

	// Return highest priority node/distance
	output reg [INDEX_WIDTH-1:0] sc_min_index,
	output reg [VALUE_WIDTH-1:0] sc_min_value,
	output reg min_ready,

	input wire [VALUE_WIDTH-1:0] dist_vector[MAX_NODES-1:0]
);

// Comb logic to get min
wire [INDEX_WIDTH-1:0] heap[2*MAX_NODES-2:0];

// Find min index/value
`define ITEMS (2*MAX_NODES-start)/2
integer i;
wire [INDEX_WIDTH-1:0] min_index;
wire [VALUE_WIDTH-1:0] min_value;
generate
	genvar k;
	for(k=0;k<MAX_NODES;k=k+1)
	begin
		assign heap[k] = k;
	end
endgenerate
generate
	genvar start;
	for(start=0;start<2*MAX_NODES-2;start=(2*MAX_NODES+start)/2)
	begin
		genvar i;
		for(i=start;i<start+`ITEMS;i=i+2)
		begin
			assign heap[MAX_NODES+i/2] =
				visited_vector[heap[i]] != `UNVISITED?
					heap[i+1]:
					visited_vector[heap[i+1]] != `UNVISITED?
						heap[i]:
						dist_vector[heap[i]] < dist_vector[heap[i+1]]?
							heap[i]:
							heap[i+1];
		end
	end
endgenerate

assign min_index = heap[2*MAX_NODES-2];
assign min_value = dist_vector[min_index];


integer countdown;

`define CYCLES_TO_WAIT 2

integer s;
integer os;
always @(reset, set_en, visited_vector)
begin
	if(reset)
	begin
	s=42;
	end
	s+=1;
end

always @(posedge clock) begin
	if(reset || set_en || os != s)
	begin
		os = s;
		countdown = `CYCLES_TO_WAIT;
		min_ready = 0;
		sc_min_index = 'z;
		sc_min_value = 'z;
	end
	else if(countdown > 0)
	begin
		countdown = countdown -1;
	end
	else
	begin
		min_ready = 1;
		sc_min_index = min_index;
		sc_min_value = min_value;
	end
end
endmodule
