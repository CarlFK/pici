#!/bin/bash -x

dist=bullseye
p=/srv/nfs/rpi/${dist}

systemctl stop nfs-server.service

umount ${p}/boot/merged
umount ${p}/root/merged

find /srv/tftp -type l -delete
rm -rf ${p}

# remove our overlay lines from fstab
sed -i "\@overlay\s*${p}/[br]oot/merged@d" /etc/fstab


