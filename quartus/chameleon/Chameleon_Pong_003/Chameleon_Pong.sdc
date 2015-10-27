## Generated SDC file "Chameleon_Pong.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition"

## DATE    "Sun Apr 22 09:36:35 2012"

##
## DEVICE  "EP3C25E144C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk8} -period 125.000 -waveform { 0.000 62.500 } [get_ports {clk8}]
create_clock -name {video_vga_master:myVgaMaster|newPixel} -period 40.000 -waveform { 0.000 0.500 } [get_registers {video_vga_master:myVgaMaster|newPixel}]
create_clock -name {video_vga_master:myVgaMaster|vSync} -period 16666.000 -waveform { 0.000 0.500 } [get_registers {video_vga_master:myVgaMaster|vSync}]
create_clock -name {usart_clk} -period 125.000 -waveform { 0.000 0.500 } [get_ports {usart_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pllInstance|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pllInstance|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 25 -divide_by 2 -master_clock {clk8} [get_pins {pllInstance|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {pllInstance|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {pllInstance|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 75 -divide_by 4 -phase 180.000 -master_clock {clk8} [get_pins {pllInstance|altpll_component|auto_generated|pll1|clk[3]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

