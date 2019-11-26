#!/usr/bin/env bash
#Build top level design

./clean.sh
vcs -full64 -sverilog -debug_all src/*.v src/*.sv +incdir+src
