#!/bin/bash

set -x

sleep_time=${1:-0}

pi_ports=$(seq 1 48)
ip_base=10.21.0
o_base=100

for p in ${pi_ports}
do
   let o=o_base+p
   pi_ip=${ip_base}.${o}
   echo "ssh pi@${pi_ip} \"sudo shutdown\""
   ssh pi@${pi_ip} "sudo shutdown"
   # poe.sh $p $1
   # sleep ${sleep_time}
done
