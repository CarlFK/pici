#!/bin/bash
# extract files from raspios.img file.

set -ex

zip_name=/var/cache/pib/2022-04-04-raspios-bullseye-armhf-lite.img.xz
img_name=/var/cache/pib/2022-04-04-raspios-bullseye-armhf-lite.img
dist=bullseye

mkdir -p /var/cache/pib/
cd /var/cache/pib/
xz --keep --decompress ${zip_name} | true

# trunk of nfs things, destination for files
nfs_dir=/srv/nfs/rpi/${dist}

losetup -P /dev/loop5 ${img_name}
partprobe

# mount point for an img partition
mkdir -p /tmp/img

mount /dev/loop5p1 /tmp/img
mkdir -p ${nfs_dir}/boot
rsync -xa --progress /tmp/img/ ${nfs_dir}/boot
umount /tmp/img

mount /dev/loop5p2 /tmp/img
mkdir -p ${nfs_dir}/root
rsync -xa --progress /tmp/img/ ${nfs_dir}/root
umount /tmp/img

losetup -d /dev/loop5
