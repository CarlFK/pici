#!/bin/sh

pistat_host=$1
hn=$2

/home/pi/Demos/counter_test/run_demo.sh
/usr/bin/curl --silent https://${pistat_host}/pistat/stat/${hn}/ArtyBlink/
