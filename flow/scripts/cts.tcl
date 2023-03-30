utl::set_metrics_stage "cts__{}"
source $::env(SCRIPTS_DIR)/load.tcl
load_design 3_place.odb 3_place.sdc "Starting CTS"

# Clone clock tree inverters next to register loads
# so cts does not try to buffer the inverted clocks.
repair_clock_inverters


##For Defining Clock Routing Layer##
if {[info exist ::env(CLOCK_ROUTING_LAYER)]} { 
set_routing_layer -clock $::env(MIN_CLOCK_ROUTING_LAYER)-$::env(MAX_CLOCK_ROUTING_LAYER)
regexp {(\w*)(\d)} $::env(MIN_CLOCK_ROUTING_LAYER) full_match name_syn min_clk_layer
regexp {(\w*)(\d)} $::env(MAX_CLOCK_ROUTING_LAYER) full_match name_syn max_clk_layer
for { set i $max_clk_layer } { $i >= $min_clk_layer} {incr i -1} {
set_wire_rc -clock -layer $name_syn$i
}
}

##To Remove Buffer Tree at first then build again## 
if {[info exist ::env(REMOVE_BUFFER_TREE)]} {
   remove_buffers
   repair_design
}

# Run CTS

##Defining Cluster size and Diameter##
if {[info exist ::env(CTS_CLUSTER_SIZE)]} {
  set cluster_size "$::env(CTS_CLUSTER_SIZE)"
} else {
  set cluster_size 30
}
if {[info exist ::env(CTS_CLUSTER_DIAMETER)]} {
  set cluster_diameter "$::env(CTS_CLUSTER_DIAMETER)"
} else {
  set cluster_diameter 100
}


##For Inserting Clk Buffer cell list##
if {[info exist ::env(CTS_BUF_DISTANCE)]} {
clock_tree_synthesis -root_buf "$::env(CTS_ROOT_BUF_CELL)" -buf_list "$::env(CTS_BUF_CELL)" \
                     -sink_clustering_enable \
                     -sink_clustering_size $cluster_size \
                     -sink_clustering_max_diameter $cluster_diameter \
                     -distance_between_buffers "$::env(CTS_BUF_DISTANCE)" \
                     -balance_levels
} else {
clock_tree_synthesis -root_buf "$::env(CTS_ROOT_BUF_CELL)" -buf_list "$::env(CTS_BUF_CELL)" \
                     -sink_clustering_enable \
                     -sink_clustering_size $cluster_size \
                     -sink_clustering_max_diameter $cluster_diameter \
                     -balance_levels
}


set_propagated_clock [all_clocks]

set_dont_use $::env(DONT_USE_CELLS)

utl::push_metrics_stage "cts__{}__pre_repair"
source $::env(SCRIPTS_DIR)/report_metrics.tcl
repair_design 
estimate_parasitics -placement
report_metrics "cts pre-repair"
utl::pop_metrics_stage

repair_clock_nets
repair_design
utl::push_metrics_stage "cts__{}__post_repair"
estimate_parasitics -placement
report_metrics "cts post-repair"
utl::pop_metrics_stage

set_placement_padding -global \
    -left $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) \
    -right $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT)
detailed_placement

estimate_parasitics -placement
repair_design
puts "Repair setup and hold violations..."
# process user settings
set additional_args ""
if { [info exists ::env(SETUP_SLACK_MARGIN)] && $::env(SETUP_SLACK_MARGIN) > 0.0} {
  puts "Setup slack margin $::env(SETUP_SLACK_MARGIN)"
  append additional_args " -setup_margin $::env(SETUP_SLACK_MARGIN)"
}
if { [info exists ::env(HOLD_SLACK_MARGIN)] && $::env(HOLD_SLACK_MARGIN) > 0.0} {
  puts "Hold slack margin $::env(HOLD_SLACK_MARGIN)"
  append additional_args " -hold_margin $::env(HOLD_SLACK_MARGIN)"
}


############ Modified to number of violating paths to repair ###############

if { [info exists ::env(REPAIR_TNS)] && $::env(REPAIR_TNS) > 0.0 } {
	puts "Total percentage of violating paths to repair repair $::env(REPAIR_TNS)"
	append additional_args " -repair_tns $::env(REPAIR_TNS)"
}

############################################################################

repair_timing {*}$additional_args
repair_design
detailed_placement
check_placement -verbose

report_metrics "cts final"

if { [info exists ::env(POST_CTS_TCL)] } {
  source $::env(POST_CTS_TCL)
}

if {![info exists save_checkpoint] || $save_checkpoint} {
  if {[info exists ::env(GALLERY_REPORT)]  && $::env(GALLERY_REPORT) != 0} {
      write_def $::env(RESULTS_DIR)/4_1_cts.def
  }
  write_db $::env(RESULTS_DIR)/4_1_cts.odb
  write_sdc $::env(RESULTS_DIR)/4_cts.sdc
}

