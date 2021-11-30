#!/bin/bash -ex

dist=bullseye
d=/srv/nfs/rpi/${dist}

p=${d}/boot
rm -rf ${p}/work/index
mount -t overlay overlay -o nfs_export=on,\
lowerdir=${p}/setup:${p}/base,\
upperdir=${p}/updates,\
workdir=${p}/work \
    ${p}/merged

p=${d}/root
rm -rf ${p}/work/index
mount -t overlay overlay -o nfs_export=on,\
lowerdir=${p}/setup:${p}/base,\
upperdir=${p}/updates,\
workdir=${p}/work \
    ${p}/merged

systemctl start nfs-server.service

