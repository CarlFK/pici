#!/bin/bash -x

# find the upstream IP
ip=$(ip -json route show default | jq ".[0].prefsrc" --raw-output)
echo ${ip}

# read from camera, send it to the IP:4444
/usr/bin/libcamera-vid -t 0 --inline --listen -o tcp://${ip}:4444
