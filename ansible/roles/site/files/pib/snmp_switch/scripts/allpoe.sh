#!/bin/bash

sleep_time=${1:-1}

for p in ${pi_ports}
do
   poe.sh $p $1
   sleep ${sleep_time}
done
