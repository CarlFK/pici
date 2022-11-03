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

# swichip=192.168.1.163
swichip=10.21.0.182
oid=iso.3.6.1.4.1.4526.11.16.1.1.1.3.1
port=$1

# show current value
#snmpget -v 3 -u admin -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \
#      ${swichip} "${oid}.$port"
/home/videoteam/snmp/bin/python3 /home/videoteam/snmp/bin/snmpget.py -v3 -l authPriv -u admin -A wordpass -X wordpass -c pib \
  ${swichip} "${oid}.$port"
# maybe set new value
if [ $# -eq 2 ]; then
    val=$2
    # snmpset -v 3 -u admin -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \
    #  ${swichip} "${oid}.$port" i "$val"
    /home/videoteam/snmp/bin/python3 /home/videoteam/snmp/bin/snmpset.py -v3 -l authPriv -u admin -A wordpass -X wordpass -c pib \
       ${swichip} "${oid}.$port" i "$val"

fi

