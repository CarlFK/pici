#!/bin/bash -x

eth=${1:-eth0}

ip=$(ip addr show ${eth} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo $ip

while true; do
    libcamera-vid --rotation 180 --fullscreen -t 0 --inline --listen -o tcp://${ip}:4444
done
