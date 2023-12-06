#!/bin/bash
# extract files from raspios.img file.

# img2files.sh {{ zip_name }} {{ img_name }} {{ dist }}

set -ex

zip_name=${1}
img_name=${2}
dist=${3}

# zip_name=${1:-/var/cache/pib/2022-04-04-raspios-bullseye-armhf-lite.img.xz}
# img_name=${2:-/var/cache/pib/2022-04-04-raspios-bullseye-armhf-lite.img}
# dist=${3:-bullseye}

xz --keep --decompress ${zip_name} | true

# trunk of nfs things, destination for files
nfs_dir=/srv/nfs/rpi/${dist}

losetup -P /dev/loop5 ${img_name}
partprobe

# mount point for an img partition
mkdir -p /tmp/img

# copy the files out of the img and into the nfs server so the pi's can get them
# /boot partition:
mount /dev/loop5p1 /tmp/img
mkdir -p ${nfs_dir}/boot
rsync -xa --progress /tmp/img/ ${nfs_dir}/boot
umount /tmp/img

# / (root) partition
mount /dev/loop5p2 /tmp/img
mkdir -p ${nfs_dir}/root
rsync -xa --progress /tmp/img/ ${nfs_dir}/root
umount /tmp/img

losetup -d /dev/loop5
