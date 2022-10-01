#!/bin/bash -x

# find the upstream IP
ip=$(ip -json route show default | jq ".[0].gateway" --raw-output)
RTMP_DEST=rtmp://${ip}/stream/$(/usr/bin/hostname --short)

/usr/bin/gst-launch-1.0 libcamerasrc ! \
    video/x-raw,colorimetry=bt709,format=NV12,interlace-mode=progressive,framerate=30/1 ! \
    v4l2h264enc extra-controls=controls,video_bitrate_mode=0,video_bitrate=1000000,repeat_sequence_header=1 ! video/x-h264,profile=high,level=\(string\)4.2 ! \
    h264parse ! \
    queue ! flvmux ! \
    rtmpsink location=$RTMP_DEST

