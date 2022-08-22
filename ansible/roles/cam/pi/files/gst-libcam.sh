#!/bin/bash -x

# find the upstream IP
# ip=$(ip -json route show default | jq ".[0].prefsrc" --raw-output)
ip=$(ip -json route show default | jq ".[0].gateway" --raw-output)
echo ${ip}

# RTMP_DEST=rtmp://${ip}/stream/${HOSTNAME}
RTMP_DEST=rtmp://${ip}/stream/$(/usr/bin/hostname --short)

/usr/bin/gst-launch-1.0 libcamerasrc ! \
    videoconvert ! x264enc bitrate=1000 tune=zerolatency ! video/x-h264 ! h264parse ! \
    queue ! flvmux name=mux ! \
    rtmpsink location=$RTMP_DEST

