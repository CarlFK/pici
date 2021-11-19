#!/bin/bash -ex

dist=bullseye
d=/srv/nfs/rpi/${dist}

p=${d}/boot
umount ${p}/merged
rm -rf ${p}/play  ${p}/work ${p}/merged
mkdir ${p}/play  ${p}/work ${p}/merged

p=${d}/root
umount ${p}/merged
rm -rf ${p}/play  ${p}/work ${p}/merged
mkdir ${p}/play  ${p}/work ${p}/merged

systemctl start nfs-server.service

