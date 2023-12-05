#!/bin/bash
set -ex

# normal.sh
# normal / production mode.
# use to get out of maintenance mode.

# things it does:
# nfs exports set to ro,
# pi overlay tmpfs,
# pi fstab: don't mount boot
# pi fstab: don't mount boot

dist=bookworm
p=/srv/nfs/rpi/${dist}
boot=${p}/boot
root=${p}/root

systemctl stop nfs-server.service

# turn on overlayroot
sed -i -E "/.*/s/overlayroot=(tmpfs)?/overlayroot=tmpfs/" ${boot}/cmdline.txt
# sed -i E 's/([[:blank:]]|^)overlayroot=[^[:blank:]]*/\1overlayroot=tmpfs/'  ${boot}/cmdline.txt

cat ${boot}/cmdline.txt

# don't automount pi's /boot
sed -i "/.boot.* nfs*/s/,auto,/,noauto,/" ${root}/etc/fstab

# done with pi files, so ro all of them:
# make the nfs shares ro
sed -i "s/rw,/ro,/" /etc/exports

systemctl start nfs-server.service

cat ${boot}/cmdline.txt
cat ${root}/etc/fstab
cat /etc/exports
