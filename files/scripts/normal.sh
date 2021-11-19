#!/bin/bash
set -ex

# normal.sh
# nfs ro, overlay tmpfs pi, don't mount boot

dist=buster
root=/srv/nfs/rpi/${dist}/root/merged

# turn on overlayroot
sed -i "/^overlayroot=.*/s/^.*$/overlayroot=\"tmpfs\"/" ${root}/etc/overlayroot.conf

# don'tautomount /boot
sed -i "/.boot nfs*/s/,auto,/,noauto,/" ${root}/etc/fstab

# make the nfs shares ro
sed -i "/.*/s/rw,/ro,/" /etc/exports
systemctl restart nfs-server.service

echo "reboot pi"

