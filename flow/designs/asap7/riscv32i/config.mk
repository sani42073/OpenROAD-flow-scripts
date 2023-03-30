export DESIGN_NICKNAME = riscv32i
export DESIGN_NAME = riscv_top
export PLATFORM    = asap7

export VERILOG_FILES = $(sort $(wildcard ./designs/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc
export ADDITIONAL_LEFS = ./platforms/$(PLATFORM)/lef/fakeram7_256x32.lef
export ADDITIONAL_LIBS = ./platforms/$(PLATFORM)/lib/fakeram7_256x32.lib

export DIE_AREA = 0 0 120 120
export CORE_AREA = 5 5 110 110

export PLACE_DENSITY = 0.65

export SYNTH_HIERARCHICAL = 1
export RTLMP_FLOW = True
# RTL_MP Settings
export RTLMP_MAX_INST = 10000
export RTLMP_MIN_INST = 5000
export RTLMP_MAX_MACRO = 4
export RTLMP_MIN_MACRO = 1
export HAS_IO_CONSTRAINTS = 1
export PLACE_PINS_ARGS = -exclude left:* -exclude right:* -exclude top:*



##For Pin Metal layer Modification##
export IO_PLACER_V            = M7



##Modification For CTS Stage##
export REMOVE_BUFFER_TREE = 1
export SETUP_SLACK_MARGIN =100
export HOLD_SLACK_MARGIN  =100
export CTS_ROOT_BUF_CELL  =CKINVDCx20_ASAP7_75t_SL
export CTS_BUF_CELL       =CKINVDCx12_ASAP7_75t_SL \
                           CKINVDCx5p33_ASAP7_75t_SL \
                           CKINVDCx6p67_ASAP7_75t_SL

##For CTS Routing Layer Modification##
export CLOCK_ROUTING_LAYER =1 
export MIN_CLOCK_ROUTING_LAYER =M3
export MAX_CLOCK_ROUTING_LAYER =M5

##For CTS Cluster Modification##
export CTS_CLUSTER_MODIFICATION = 1
export CTS_CLUSTER_SIZE      = 10
export CTS_CLUSTER_DIAMETER      = 30


##For Routing Modification##
export MAX_ROUTING_LAYER       = M8

