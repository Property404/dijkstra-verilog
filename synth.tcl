lappend search_path src/
define_design_lib WORK -path work
source common.tcl

puts "|Analyzing"
analyze -library WORK -format sverilog dijkstra_top.sv
analyze -library WORK -format sverilog priority_queue.sv
analyze -library WORK -format sverilog minheap.sv
analyze -library WORK -format sverilog writer.sv
analyze -library WORK -format verilog edge_cache.v

puts "|Elaborating"
elaborate -architecture verilog -library WORK DijkstraTop

puts "|Design check"
check_design > reports/synth_check_design.rpt

puts "|Constraints"
set_max_area 0

#foreach clock_period {5 4 3} {
#	create_clock clock -name ideal_clock_${clock_period} -period ${clock_period}
#	foreach map_effort {none medium high} {
#		foreach area_effort {none low medium high} {
#			compile -map_effort $map_effort -area_effort $area_effort
#			set dir "reports/${clock_period}_clock_${map_effort}_map_${area_effort}_area"
#			file mkdir $dir
#			report_area > $dir/area.rpt
#			report_timing > $dir/timing.rpt
#			report_resources > $dir/resources.rpt
#			report_constraints > $dir/constraints.rpt
#			report_qor > $dir/qor.rpt
#			check_design > $dir/post_check_design.rpt
#		}
#	}
#}

create_clock clock -name actual_clock_2 -period 50
compile -map_effort low -area_effort low
set dir "reports/chosen"
file mkdir $dir
report_area > $dir/area.rpt
report_timing > $dir/timing.rpt
report_resources > $dir/resources.rpt
report_constraints > $dir/constraints.rpt
report_qor > $dir/qor.rpt
check_design > $dir/post_check_design.rpt

# Print out synthesized db and gate netlist
write_sdc constraints/dijkstra.sdc
write -f ddc -hierarchy -output output/dijkstra.ddc
write -hierarchy -format verilog -output output/dijkstra.v

quit
