## .xdc for the Arty A7-35 Rev. D and Rev. E
#
## Pmod Header JA

set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { ja0 }]; #IO_0_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { ja1 }]; #IO_L4P_T0_15 Sch=ja[2]
