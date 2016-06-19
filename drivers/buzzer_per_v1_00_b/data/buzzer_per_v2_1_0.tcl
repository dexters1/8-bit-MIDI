##############################################################################
## Filename:          C:\Users\student\Downloads\lab5-master\lab5-master/drivers/buzzer_per_v1_00_b/data/buzzer_per_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Sun Jun 19 15:54:56 2016 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "buzzer_per" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
