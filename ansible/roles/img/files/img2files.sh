#!/bin/bash
# extract files from raspios.img file.

set -ex

img_name=/var/cache/pib/2022-04-04-raspios-bullseye-armhf-lite.img
img_name=/var/cache/pib/2021-10-30-raspios-bullseye-armhf-lite.img
dist=bullseye

# trunk of nfs things, destination for files
nfs_dir=/srv/nfs/rpi/${dist}

losetup -P /dev/loop5 ${img_name}
partprobe

# mount point for an img partition
mkdir -p /tmp/img

mount /dev/loop5p1 /tmp/img
mkdir ${nfs_dir}/boot
rsync -xa --progress /tmp/img/ boot
umount /tmp/img

mount /dev/loop5p2 /tmp/img
mkdir ${nfs_dir}/root
rsync -xa --progress /tmp/img/ root
umount /tmp/img

losetup -d /dev/loop5
