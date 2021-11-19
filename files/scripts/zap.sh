#!/bin/bash -x

# dist=buster
dist=bullseye
systemctl stop nfs-server.service
umount /srv/nfs/rpi/${dist}/boot/merged
umount /srv/nfs/rpi/${dist}/root/merged

rm /srv/tftp/f1b7bb5a
rm /srv/tftp/e0c074cd
rm -rf /srv/nfs/rpi/${dist}

