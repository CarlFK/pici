#!/bin/bash

# $1: 1=on, 2=off
# $2: seconds to sleep between commands

sleep_time=${2:-1}

for p in ${pi_ports}
do
   poe.sh $p $1
   sleep ${sleep_time}
done
