#!/bin/bash -x

key=$1
url="rtmp://a.rtmp.youtube.com/live2/x/${key}"

/usr/bin/gst-launch-1.0 \
    libcamerasrc ! \
      video/x-raw,colorimetry=bt709,format=NV12,interlace-mode=progressive ! \
      clockoverlay shaded-background=true !\
      v4l2h264enc min-force-key-unit-interval=4000000 extra-controls=controls,video_bitrate_mode=0,video_bitrate=1000,repeat_sequence_header=1 ! \
      video/x-h264,profile=high,level=\(string\)"4.2" ! \
    h264parse ! \
    queue ! \
    flvmux name=mux ! \
    rtmpsink location=${url} \
    audiotestsrc is-live=true ! audioconvert ! audioresample ! audio/x-raw,rate=48000 ! \
      voaacenc bitrate=96000 ! audio/mpeg ! aacparse ! audio/mpeg, mpegversion=4 ! mux.
