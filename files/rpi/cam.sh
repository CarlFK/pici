#!/bin/bash -x

if [ $# -eq 0 ]; then
    ip=$(host $(hostname) |cut -d" " -f 4)
else
    eth=${1}
    ip=$(ip addr show ${eth} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
fi

echo $ip

while true; do
    libcamera-vid --rotation 180 --fullscreen -t 0 --inline --listen -o tcp://${ip}:4444
done
