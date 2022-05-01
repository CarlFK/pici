#!/bin/bash -ex

# poe.sh port 1|2
# 1=on, 2=off

# no parameters shows status of 26,30,36 (ports currently in use)

# http://oid-info.com/get/1.3.6.1.2.1.2.2.1.7

# Netgear S3300-52X-PoE+
# Sytem, SNMP, Community Configuration,
# Management Station IP: 10.21.0.1 (server's eth-local IP)
# Management Station IP Mask: 255.255.255.255 (only the server)
# Community String: pib (used in netgear/poe.sh)
# Access Mode: ReadWrite
# Status: Enable
# (Add)

# sudo apt install snmp

# Tims's
# Netgear S3300-52X-PoE+
# swichip=10.21.0.171  # Tim's
# oid=iso.3.6.1.2.1.105.1.1.1.3.1

# Carl's
# Netgear FS728TPv2
# a0:21:b7:af:4e:05
# They used a draft version of the PoE MIBs, but put it inside some Netgear model-specific OID instead
# Netgear custom based on a draft of SNMP PoE spec

swichip=192.168.1.163
oid=iso.3.6.1.4.1.4526.11.16.1.1.1.3.1

if [ $# -eq 0 ]; then
    # for port in 26 30 36; do
    for port in 1 2 3 4 5; do
        snmpget -v1 -c pib ${swichip} ${oid}.$port
    done
else
    snmpset -v 3 -u admin -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \
      ${swichip} "${oib}.$1" i "$2"
fi

