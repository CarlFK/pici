#!/bin/bash -ex

# poe.sh port 1|2
# 1=on, 2=off

# no parameters shows status of 26,30,36 (ports currently in use)

# Netgear S3300-52X-PoE+
# Sytem, SNMP, Community Configuration,
# Management Station IP: 10.21.0.1 (server's eth-local IP)
# Management Station IP Mask: 255.255.255.255 (only the server)
# Community String: pib (used in netgear/poe.sh)
# Access Mode: ReadWrite
# Status: Enable
# (Add)

# sudo apt intall snmp

if [ $# -eq 0 ]; then
    for port in 26 30 36; do
        snmpget -v1 -c pib 10.21.0.171 iso.3.6.1.2.1.105.1.1.1.3.1.$port
    done
else
    snmpset -v1 -c pib 10.21.0.171 iso.3.6.1.2.1.105.1.1.1.3.1.$1 i $2
fi
