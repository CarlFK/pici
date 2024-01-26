#!/bin/bash -ex

# mkpi.sh - flashes and configs an SD card for pi

img_host=http://downloads.raspberrypi.org

img_path=raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11
zip_name=2023-12-11-raspios-bookworm-arm64-lite.img.xz

# dev=/dev/mmcblk0
# dev=/dev/sda
dev=$1

# dir to store 400M compressed image file
cache=cache

# try to make sure the sd card/partitions are not mounted:
for p in ${dev}* ${dev}p?
    do pumount $p || true
done

# download the image file
# -N - don't download the same thing twice.
wget -N --directory-prefix=${cache} ${img_host}/${img_path}/${zip_name}

# decompress the image file and stream it to the sd card:
xz --decompress --stdout ${cache}/${zip_name}|sudo dcfldd of=${dev}
