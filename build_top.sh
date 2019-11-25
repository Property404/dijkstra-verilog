#!/usr/bin/env bash
#Build top testbench

SRC_DIR=src
OUT_FILE=testbench_results.txt
TESTBENCH_DIR=${SRC_DIR}/testbenches/
TESTBENCH=${TESTBENCH_DIR}/top_tb.sv

./clean.sh
vcs -full64 -sverilog -debug_all src/*.v src/*.sv ${TESTBENCH_DIR}block_ram.v ${TESTBENCH} +incdir+src
