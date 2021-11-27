#!/bin/bash
set -ex

# normal.sh
# nfs ro, overlay tmpfs pi, don't mount boot

dist=bullseye
p=/srv/nfs/rpi/${dist}
boot=${p}/boot/merged
root=${p}/root/merged

# turn on overlayroot
sed -i "/.*/s/overlayroot= /overlayroot=tmpfs/" ${boot}/cmdline.txt

# don't automount pi's /boot
sed -i "/.boot nfs*/s/,auto,/,noauto,/" ${root}/etc/fstab

# make the nfs shares ro
sed -i "/.*/s/rw,/ro,/" /etc/exports
systemctl restart nfs-server.service

echo "reboot pi"

