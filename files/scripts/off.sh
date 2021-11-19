#!/bin/bash -x

dist=bullseye
systemctl stop nfs-server.service
umount /srv/nfs/rpi/${dist}/boot/merged
umount /srv/nfs/rpi/${dist}/root/merged

