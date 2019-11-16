#!/usr/bin/env bash
EXECUTABLE=mkvector
OUTPUT=testvectors.txt
MIN_SIZE=4
MAX_SIZE=4
TESTS_PER_SIZE=1 
NUM_TEST_CASES=$((TESTS_PER_SIZE*(MAX_SIZE-MIN_SIZE+1)))

# Build generator
if [ ! -f $EXECUTABLE ]; then
	echo "Compiling $EXECUTABLE"
	g++ *.cpp -o $EXECUTABLE -fmax-errors=2 -Wall
fi

# Create new output file
rm -f $OUTPUT
echo $NUM_TEST_CASES > $OUTPUT

# Make vectors
for size in $(seq $MIN_SIZE 1 $MAX_SIZE)
do
	for j in $(seq 1 1 $TESTS_PER_SIZE)
	do
		./$EXECUTABLE -m -n $size -s $((RANDOM%65536)) >> $OUTPUT
	done
done



