#!/bin/sh

pistat_host=$1
hn=$2

if /usr/local/bin/arty_here.exp
then
  /usr/bin/curl --silent https://${pistat_host}/pistat/stat/${hn}/ArtyHere/
else
  /usr/bin/curl --silent https://${pistat_host}/pistat/stat/${hn}/NoArty/
fi
