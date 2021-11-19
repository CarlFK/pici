#!/bin/bash
set -ex

# maintenance.sh
# give pi's (all of them) rw access to the nfs shares, mount /boot

dist=bullseye
root=/srv/nfs/rpi/${dist}/root/merged

# turnoff overlayroot
sed -i "/^overlayroot=.*/s/^.*$/overlayroot=\"\"/" ${root}/etc/overlayroot.conf

# automount /boot
sed -i "/.boot nfs*/s/,noauto,/,auto,/" ${root}/etc/fstab

# make the nfs shares rw
sed -i "/.*/s/ro,/rw,/" /etc/exports
systemctl restart nfs-server.service

