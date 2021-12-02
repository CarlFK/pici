#!/bin/bash -ex

# poe.sh port 1|2
# 1=on, 2=off

# sudo apt intall snmp
snmpset -v1 -c public 10.21.0.171 iso.3.6.1.2.1.105.1.1.1.3.1.$1 i $2
