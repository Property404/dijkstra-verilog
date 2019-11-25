gui_start
lappend search_path ../../src
define_design_lib WORK -path work
#set link_library [list /apps/synopsys2017/cafe/SAED/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_max.db /apps/synopsys2017/cafe/SAED/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_min.db /apps/synopsys2017/cafe/SAED/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db]
#set target_library [list /apps/synopsys2017/cafe/SAED/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_max.db]
source ../lib-gen/lib_container.tcl
set_svf "gcd_syn.svf"
analyze -library WORK -format sverilog "gcd_control.sv gcd_datapath.sv gcd_top.sv"
elaborate -architecture verilog -library WORK "GCD_Calculator"
link
create_clock clk -name ideal_clock1 -period 20
set_max_area 0
compile -map_effort medium -area_effort medium
check_design
set_svf -off
report_timing -transition_time -nets -attributes -nosplit > reports/gcd_timing.rpt
report_area -nosplit -hierarchy > reports/gcd_area.rpt
report_power -nosplit -hier > reports/gcd_power.rpt
report_qor  > reports/gcd_qor.rpt
report_constraints > reports/gcd_constraints.rpt
report_hierarchy > reports/gcd_hierarchy.rpt
report_resources > reports/gcd_resources.rpt
report_reference > reports/gcd_reference.rpt
change_names -rules verilog -hierarchy
write -format ddc -hierarchy -output output/gcd_syn.ddc
write -f verilog -hierarchy -output output/gcd_syn.sv
write_sdc -version 1.7 -nosplit output/gcd_syn.sdc
quit

