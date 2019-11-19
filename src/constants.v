// Number of nodes we're working with
`define DEFAULT_MAX_NODES 128
`define DEFAULT_INDEX_WIDTH 8

// Width of the edge value
// Max edge value is 2**VALUE_WIDTH-1
`define DEFAULT_VALUE_WIDTH 8 

// RAM width
`define DEFAULT_MADDR_WIDTH 16
`define DEFAULT_MDATA_WIDTH 8

`define INFINITY ((2**VALUE_WIDTH)-1)
`define NO_PREVIOUS_NODE ((2**INDEX_WIDTH)-1)

`define UNVISITED 0
`define VISITED 1

