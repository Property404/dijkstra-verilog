SRC_DIR=src
TESTBENCH_DIR=${SRC_DIR}/testbenches
#TESTBENCH=${TESTBENCH_DIR}/priority_queue_tb.sv
TESTBENCH=${TESTBENCH_DIR}/top_tb.sv
vcs -full64 -sverilog -debug_all src/*.v src/*.sv src/testbenches/block_ram.v $TESTBENCH +incdir+src
