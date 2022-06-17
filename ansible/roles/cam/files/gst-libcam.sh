set -ex
#!/bin/bash -x


# find the upstream IP
# ip=$(ip -json route show default | jq ".[0].prefsrc" --raw-output)
ip=$(ip -json route show default | jq ".[0].gateway" --raw-output)
echo ${ip}

RTMP_DEST=rtmp://${ip}/stream/${HOSTNAME}

gst-launch-1.0 libcamerasrc ! \
    videoconvert ! x264enc bitrate=1000 tune=zerolatency ! video/x-h264 ! h264parse ! \
    video/x-h264 ! queue ! flvmux name=mux ! \
    rtmpsink location=$RTMP_DEST audiotestsrc is-live=true ! \
    audioconvert ! audioresample ! audio/x-raw,rate=48000 ! \
    voaacenc bitrate=96000 ! audio/mpeg ! aacparse ! audio/mpeg, mpegversion=4 ! mux.

