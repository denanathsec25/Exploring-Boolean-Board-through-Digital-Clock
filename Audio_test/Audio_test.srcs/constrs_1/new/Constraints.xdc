create_clock -period 10.000 -name sys_clk [get_ports clk]


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports left_audio_out]
set_property IOSTANDARD LVCMOS33 [get_ports right_audio_out]
set_property PACKAGE_PIN N13 [get_ports left_audio_out]
set_property PACKAGE_PIN N14 [get_ports right_audio_out]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN F14 [get_ports clk]
set_property PACKAGE_PIN J1 [get_ports rst]

set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

