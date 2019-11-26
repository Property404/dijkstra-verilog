source lib_container.tcl

proc dm_setup {base_name path} {
	set library_name ${base_name}LIB

	# Go to ICC directory
	cd ${path}
	file mkdir output

	#Create a new Milkyway library for your design (“$library_name”), and open the
	#newly created library.  Before you jump into place and route, you will create
	#your own Milkyway database, the place where you will be saving your place and
	#routed design. Notice while you create the Milkyway database you hand in the
	#technology file which has all the information about the process (e.g.,
	#detailed information of the poly and the metal layers), and the Milkyway
	#reference database which captures the standard cell layout.
	puts "Create MilkyWay lib"
	create_mw_lib -technology "/apps/synopsys2017/cafe/SAED/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf" -mw_reference_library {"/apps/synopsys2017/cafe/SAED/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m" "/apps/synopsys2017/cafe/SAED/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m" "/apps/synopsys2017/cafe/SAED/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m"} "$library_name"
	open_mw_lib $library_name

	#Import your design.  Now that our environment is configured, we can import our
	#work from last laboratory. This results in a lot of output as well. It opens
	#up a layout window, which contains the layout information as shown below. You
	#can see all the cells in the design at the bottom, since we have not
	#initialized the floorplan yet or done any placement. Between commands,
	#checking the layout window is a good way to visually see what the operation
	#has done; many of the operations effect the location of parts, the
	#connections, chip buses, etc, and these parts and changes are all represented
	#in the layout window.
	puts "Import design"
	import_designs "../output/${base_name}.ddc" -format "ddc" -top "${base_name}count" -cel "${base_name}count" 

	#In addition, we can read the timing constraints for the design by using the
	#read_sdc command (or by choosing File > Import > Read SDC in the GUI).
	puts "Read timing constraints"
	read_sdc ../constraints/${base_name}.sdc

	#Then you will specify the tlu+ files which have the information you will use
	#when extracting the parasitics of the layout.
	puts "Specify tlu+ files"
	set_tlu_plus_files -max_tluplus "/apps/synopsys2017/cafe/SAED/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus" -min_tluplus "/apps/synopsys2017/cafe/SAED/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus" -tech2itf_map "/apps/synopsys2017/cafe/SAED/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map"

	#After this step you can opt to save your current design:
	save_mw_cel -as ${base_name}_init
}

proc dm_create_floorplan {base_name} {
	set library_name ${base_name}LIB
	###############
	#FLOORPLANNING#
	###############

	#Initialize the floorplan
	create_floorplan -core_utilization 0.6 -start_first_row -left_io2core "30" -bottom_io2core "30" -right_io2core "30" -top_io2core "30"
}

proc dm_power {base_name} {
	set library_name ${base_name}LIB

	#Make power and ground ports.  
	derive_pg_connection -power_net "VDD" -power_pin "VDD" -ground_net "VSS" -ground_pin "VSS" -create_ports "top"

	#Create rectangular rings for the ground and power.
	create_rectangular_ring -nets {VSS} -left_offset 0.5 -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 0.5 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 0.5 -bottom_segment_layer M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 0.5 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th
	create_rectangular_ring -nets {VDD} -left_offset 1.8 -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 1.8 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 1.8 -bottom_segment_layer M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 1.8 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th

	#Create ground and power straps.
	create_power_strap -nets {VSS} -layer M6 -direction vertical -width 3
	create_power_strap -nets {VDD} -layer M6 -direction vertical -width 3

}

proc dm_place_fp {base_name} {
	set library_name ${base_name}LIB

	# Create initial placement
	create_fp_placement

	# Savepoint
	save_mw_cel -as ${base_name}_fp
}

proc dm_synthesize_clock {base_name} {
	set library_name ${base_name}LIB


	###########
	#PLACEMENT#
	###########

	#Optimize placement
	place_opt

	#Synthesize clock tree
	clock_opt

	#Save the cell. Generate reports. Inspect the content of these reports. Note:
	#create an output subdirectory where these reports are kept (see below).
	save_mw_cel -as ${base_name}_cts_opt
	report_placement_utilization > output/${base_name}_cts_util.rpt
	report_qor > output/${base_name}_cts_qor.rpt
	report_timing -delay max -max_paths 5 > output/${base_name}_cts.setup.rpt
	report_timing -delay min -max_paths 5 > output/${base_name}_cts.hold.rpt
}

proc dm_fill {base_name} {
	set library_name ${base_name}LIB

	#########
	#Routing#
	#########

	#Insert standard cell fillers (observe the changes in your design).
	insert_stdcell_filler -cell_with_metal "SHFILL2" -cell_without_metal "SHFILL2" -connect_to_power {VDD} -connect_to_ground {VSS}
}

proc dm_route {base_name} {
	set library_name ${base_name}LIB

	#Route design
	route_opt

	#Verify the routing. Analyze the output.
	verify_zrt_route

	#Generate reorts
	report_placement_utilization > output/${base_name}_route_util.rpt
	report_qor > output/${base_name}_route_qor.rpt
	report_timing -delay max -max_paths 5 > output/${base_name}_route.setup.rpt
	report_timing -delay min -max_paths 5 > output/${base_name}_route.hold.rpt

	#Extract parasitics
	extract_rc -coupling_cap
	write_parasitics -format SBPF -output output/${base_name}.output.sbpf

	#Write output Verilog and SDC files
	write_verilog output/$library_name.output.v
	write_sdc output/$library_name.output.sdc

	# Save and quit
	save_mw_cel -as ${base_name}_route
}

proc dm_finish {base_name} {
	close_mw_cel
}
