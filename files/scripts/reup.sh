#!/bin/bash -ex

# blow away everything but base and setup.
# base is the img
# setup is put in place by setup2.sh
# updates is done by the pi
# whack play just for good measure

dist=bullseye
d=/srv/nfs/rpi/${dist}

systemctl stop nfs-server.service

p=${d}/boot
umount ${p}/merged
rm -rf ${p}/work/index
rm -rf ${p}/updates ${p}/play
mkdir  ${p}/updates ${p}/play
mount -t overlay overlay -o nfs_export=on,\
lowerdir=${p}/setup:${p}/base,\
upperdir=${p}/updates,\
workdir=${p}/work \
    ${p}/merged

p=${d}/root
umount ${p}/merged
rm -rf ${p}/work/index
rm -rf ${p}/updates ${p}/play
mkdir  ${p}/updates ${p}/play
mount -t overlay overlay -o nfs_export=on,\
lowerdir=${p}/setup:${p}/base,\
upperdir=${p}/updates,\
workdir=${p}/work \
    ${p}/merged

systemctl start nfs-server.service

