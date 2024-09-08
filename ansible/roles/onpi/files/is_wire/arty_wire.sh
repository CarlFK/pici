#!/bin/sh

pistat_host=$1
hn=$2

if /home/pi/ci/t1/t1.sh
then
  /usr/bin/curl --silent https://${pistat_host}/pistat/stat/${hn}/ArtyWire/
else
  /usr/bin/curl --silent https://${pistat_host}/pistat/stat/${hn}/ArtyNoWire/
fi
