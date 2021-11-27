#!/bin/bash
set -ex

# maintenance.sh
# give pi's (all of them) rw access to the nfs shares, mount /boot

dist=bullseye
p=/srv/nfs/rpi/${dist}
boot=${p}/boot/merged
root=${p}/root/merged

# turnoff overlayroot
sed -i "/.*/s/overlayroot=tmpfs/overlayroot=/" ${boot}/cmdline.txt

# automount /boot
sed -i "/.boot nfs*/s/,noauto,/,auto,/" ${root}/etc/fstab

# make the nfs shares rw
sed -i "/.*/s/ro,/rw,/" /etc/exports
systemctl restart nfs-server.service

