#!/bin/bash -x

if [ $# -eq 0 ]; then
    eth=$(route -n|grep 10.21.0.1|awk '{print $8}')
else
    eth=${1}
fi
ip=$(ip addr show ${eth} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

echo $ip

while true; do
    libcamera-vid --rotation 180 --fullscreen -t 0 --inline --listen -o tcp://${ip}:4444
done
