set fo [open ./lib_container.tcl "w"]
set lib_path "/apps/synopsys2017/cafe/SAED/SAED32_EDK/lib"

puts "MultiThreshold Design?:\[yes/no\]"
set MVT [gets stdin]

if { $MVT == "no"} {
	puts "Define Standard Cell Type\[hvt lvt or rvt\]: "
	set stdCellType [gets stdin]
	puts "Enter DB\[ccs or nldm\]: "
	set DB [gets stdin]
	set lib_path "$lib_path/stdcell_$stdCellType/db_$DB/"
	puts "Choose Characterization Corner\[typ middle low\]: "
	set CORNER [gets stdin]
	if {$CORNER == "typ"} {
		set lib_list [eval [list exec ls ] [glob $lib_path/*vt_ff*16*db $lib_path/*vt_ss*95*db $lib_path/*vt_tt*05*db ]]
	} elseif  {$CORNER == "middle"} {
		set lib_list [eval [list exec ls ] [glob $lib_path/*vt_ff*95*db $lib_path/*vt_ss*75*db $lib_path/*vt_tt*85*db ]]
	} elseif  {$CORNER == "low"} {
		set lib_list [eval [list exec ls ] [glob $lib_path/*vt_ff*85*db $lib_path/*vt_ss*7v*db $lib_path/*vt_tt*78*db ]]
	}
}  else {
	puts "Enter DB\[ccs or nldm\]: "
	set DB [gets stdin]
	puts "Choose Characterization Corner\[typ middle low\]: "
	set CORNER [gets stdin]
	if {$CORNER == "typ"} {
		set lib_list [eval [list exec ls ] [glob  $lib_path/stdcell_lvt/db_$DB/*vt_ff*16*db $lib_path/stdcell_lvt/db_$DB/*vt_ss*95*db $lib_path/stdcell_lvt/db_$DB/*vt_tt*05*db $lib_path/stdcell_hvt/db_$DB/*vt_ff*16*db $lib_path/stdcell_hvt/db_$DB/*vt_ss*95*db $lib_path/stdcell_hvt/db_$DB/*vt_tt*05*db ]]
	} elseif  {$CORNER == "middle"} {
		set lib_list [eval [list exec ls ] [glob  $lib_path/stdcell_lvt/db_$DB/*vt_ff*95*db $lib_path/stdcell_lvt/db_$DB/*vt_ss*75*db $lib_path/stdcell_lvt/db_$DB/*vt_tt*85*db $lib_path/stdcell_hvt/db_$DB/*vt_ff*95*db $lib_path/stdcell_hvt/db_$DB/*vt_ss*75*db $lib_path/stdcell_hvt/db_$DB/*vt_tt*85*db ]]
	} elseif  {$CORNER == "low"} {
		set lib_list [eval [list exec ls ] [glob  $lib_path/stdcell_hvt/db_$DB/*vt_ff*85*db $lib_path/stdcell_hvt/db_$DB/*vt_ss*7v*db $lib_path/stdcell_hvt/db_$DB/*vt_tt*78*db $lib_path/stdcell_lvt/db_$DB/*vt_ff*85*db $lib_path/stdcell_lvt/db_$DB/*vt_ss*7v*db $lib_path/stdcell_lvt/db_$DB/*vt_tt*78*db ]]
	}
}

puts $fo "set link_library  \\"

set llib_list [lsearch -all -inline $lib_list *.db*]
puts $fo  [concat \[ list * $llib_list \]]

puts "Define PVT Corner for Target Libs \[ff tt or ss\]: "
set PVT [gets stdin]

set tlib_list [lsearch -all -inline $lib_list *_$PVT*]

puts $fo "set target_library  \\"
puts $fo [concat \[list  $tlib_list \]]

close $fo