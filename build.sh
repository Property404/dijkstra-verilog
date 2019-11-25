set -e
SRC_DIR=src
OUT_FILE=testbench_results.txt
TESTBENCH_DIR=${SRC_DIR}/testbenches/
TESTBENCHES=(block_ram_tb.v priority_queue_tb.sv top_tb.sv writer_tb.sv edge_cache_tb.sv)

echo "TESTBENCH RESULTS" > $OUT_FILE
echo "Generated $(date)" >> $OUT_FILE
echo "~~~~~~~~~~~~~~~~~~" >> $OUT_FILE
echo >> $OUT_FILE

for testbench in "${TESTBENCHES[@]}"
do
	echo "Testbench: ${testbench}" >> $OUT_FILE
	./clean.sh
	vcs -full64 -sverilog -debug_all src/*.v src/*.sv src/testbenches/block_ram.v ${TESTBENCH_DIR}${testbench} +incdir+src
	./simv | tee -a $OUT_FILE
	echo "~~~~~~~~~~~~~~~~~~" >> $OUT_FILE
	echo >> $OUT_FILE
done
