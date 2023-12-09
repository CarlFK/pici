#!/bin/bash

set -x

sleep_time=${1:-10}

pi_ports=$(seq 1 48)
ip_base=10.21.0
o_base=100

# issue shutdown command to all the pis:
# no wait, this is poiteless.
# they are all overlayrooted, so the fs is in ram.
for p in ${pi_ports}
do
   let o=o_base+p
   pi_ip=${ip_base}.${o}
   # ssh pi@${pi_ip} "sudo shutdown"
   # sleep ${sleep_time}
done

# sleep ${sleep_time}

# drop power all the ports
for p in ${pi_ports}
do
   let o=o_base+p
   pi_ip=${ip_base}.${o}
   poe.sh $p 2
done
