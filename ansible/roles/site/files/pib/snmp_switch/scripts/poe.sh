#!/bin/bash -ex

# poe.sh $port 1|2
# 1=on, 2=off

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
swichip=10.21.0.200
oid=iso.3.6.1.2.1.105.1.1.1.3.1

# James's
# Netgear FS728TPv2
# a0:21:b7:af:4e:05
# They used a draft version of the PoE MIBs, but put it inside some Netgear model-specific OID instead
# Netgear custom based on a draft of SNMP PoE spec

# swichip=192.168.1.163
# swichip=10.21.0.182
# oid=iso.3.6.1.4.1.4526.11.16.1.1.1.3.1

# Carl's
# Netgear GS728TPP
# swich1ip=192.168.1.132
# swich2ip=192.168.1.111

port=$1

. /srv/www/pib/venv/bin/activate

# show current value
# snmpget -v 3 -u admin -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \
#      ${swichip} "${oid}.$port"
# snmpget.py -v3 -l authPriv -u admin -A wordpass -X wordpass -c pib \

snmpget.py -v 3 -u ${SNMP_SWITCH_USERNAME} \
    -c pib \
    -l ${SNMP_SWITCH_SECURITY_LEVEL} -a ${SNMP_SWITCH_AUTH_PROTOCOL}  -A ${SNMP_SWITCH_PASSPHRASE} \
  ${swichip} "${oid}.$port"
# maybe set new value
if [ $# -eq 2 ]; then
    val=$2
    # snmpset -v 3 -u admin -l authPriv -a MD5 -x DES -A wordpass -X wordpass -c pib \
    #  ${swichip} "${oid}.$port" i "$val"
    # snmpset.py -v3 -l authPriv -u admin -A wordpass -X wordpass -c pib \
    snmpset.py -v 3 -u admin -l authNoPriv -a SHA512 -A WordPass207 -c pib \
       ${swichip} "${oid}.$port" i "$val"

fi

