#!/bin/bash

# poe.sh port 1|2
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

# Tims's
# Netgear S3300-52X-PoE+
# swichip=10.21.0.200
# oid=iso.3.6.1.2.1.105.1.1.1.3.1

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

#   -u SECURITY-NAME      SNMP USM user security name (e.g. bert)
#   -l SECURITY-LEVEL     security level (noAuthNoPriv|authNoPriv|authPriv)
#   -a AUTH-PROTOCOL      authentication protocol ID (MD5|SHA|SHA224|SHA256|SHA384|SHA512)
#   -A PASSPHRASE         authentication protocol pass phrase (8+ chars)
#   -x PRIV-PROTOCOL      privacy protocol ID (3DES|AES|AES128|AES192|AES192BLMT|AES256|AES256BLMT|DES)
#   -X PASSPHRASE         privacy protocol pass phrase (8+ chars)

#   -x privProtocol
#      Set  the  privacy protocol (DES or AES) used for encrypted SNMPv3 messages.  Overrides the defPrivType
#      token in the snmp.conf file. This option is only valid if the  Net-SNMP  software  was  build  to  use OpenSSL.
#   -X privPassword
#      Set the privacy pass phrase used for encrypted SNMPv3 messages.  Overrides the defPrivPassphrase token
#      in the snmp.conf file.  It is insecure to specify pass phrases on the command line, see snmp.conf(5).

snmpget.py -v 3 \
    -u ${SNMP_SWITCH_USERNAME} \
    -l ${SNMP_SWITCH_SECURITY_LEVEL} \
    -a ${SNMP_SWITCH_AUTH_PROTOCOL}  \
    -A ${SNMP_SWITCH_PASSPHRASE} \
    -x ${SNMP_SWITCH_PRIV_PROTOCOL} \
    -X ${SNMP_SWITCH_PRIV_PASSPHRASE} \
  ${SNMP_SWITCH_HOST} "${SNMP_SWITCH_OID}.$port"

# maybe set new value
if [ $# -eq 2 ]; then
    val=$2
    snmpset.py -v 3 \
        -u ${SNMP_SWITCH_USERNAME} \
        -l ${SNMP_SWITCH_SECURITY_LEVEL} \
        -a ${SNMP_SWITCH_AUTH_PROTOCOL}  \
        -A ${SNMP_SWITCH_PASSPHRASE} \
        -x ${SNMP_SWITCH_PRIV_PROTOCOL} \
        -X ${SNMP_SWITCH_PRIV_PASSPHRASE} \
      ${SNMP_SWITCH_HOST} "${SNMP_SWITCH_OID}.$port" i "$val"
fi

