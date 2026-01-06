#!/bin/bash -x

# hostname
hn=$(/usr/bin/hostname --short)

# find the upstream IP and nic dev
# this is clever, but should probably be an os var managed by ansible.
ip=$(ip -json route show default | jq ".[0].gateway" --raw-output)
dev=$(ip -json route show default | jq ".[0].dev" --raw-output)

# while [ "${hn}" = "localhost" ]
# do
#     echo ${hn} "is still localhost"
#     # this should really be in its own systemd script.
#     # it works around some bug in
#     # https://github.com/isc-projects/dhcp/blob/master/client/scripts/linux#L121
#     /usr/sbin/dhclient -v ${dev}
#     hn=$(/usr/bin/hostname --short)
# done

RTMP_DEST=rtmp://${ip}/pib/${hn}

# figure out if we can use v4l2 hardware encoding (pi 5 says No.)
if (gst-inspect-1.0 --exists v4l2h264enc); then
    venc="v4l2h264enc extra-controls=controls,video_bitrate_mode=0,video_bitrate=1000000,repeat_sequence_header=1"
else
    venc="x264enc bitrate=2000 byte-stream=false key-int-max=60 bframes=0 aud=true tune=zerolatency"
fi

# example of using encode bin to select encoder
# gst-launch-1.0 videotestsrc ! video/x-raw,width=640,height=480 ! queue ! \
#   encodebin ! h264parse ! qtmux ! filesink location=output.mp4

/usr/bin/gst-launch-1.0 libcamerasrc ! \
    video/x-raw,colorimetry=bt709,format=NV12,interlace-mode=progressive,framerate=6/1 ! \
    clockoverlay shaded-background=true !\
    ${venc} !\
    video/x-h264,profile=high,level=\(string\)4.2 ! \
    h264parse ! \
    queue ! flvmux ! \
    rtmpsink location=$RTMP_DEST

