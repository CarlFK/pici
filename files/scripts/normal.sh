#!/bin/bash
set -ex

# normal.sh
# nfs ro, overlay tmpfs pi, don't mount boot

dist=bullseye
p=/srv/nfs/rpi/${dist}
boot=${p}/boot/merged
root=${p}/root/merged

systemctl stop nfs-server.service

umount ${p}/boot/merged || true
umount ${p}/root/merged || true

rm -rf ${p}/boot/work/index
rm -rf ${p}/root/work/index

mount -o rw ${p}/boot/merged
mount -o rw ${p}/root/merged

# turn on overlayroot
sed -i "/.*/s/overlayroot=(tmpfs)?/overlayroot=tmpfs/" ${boot}/cmdline.txt
cat ${boot}/cmdline.txt

# don't automount pi's /boot
sed -i "/.boot nfs*/s/,auto,/,noauto,/" ${root}/etc/fstab

# done with pi files, so ro all of them:
mount -o remount,ro ${p}/boot/merged
mount -o remount,ro ${p}/root/merged

# make the nfs shares ro
sed -i "/.*/s/rw,/ro,/" /etc/exports
systemctl start nfs-server.service

# server enable automount the stack of pi files
# (this risks bricking the server with:
#  overlayfs: failed to verify index dir 'upper' xattr
# sed -i "\@overlay\s*${p}/[br]oot/merged@s@\bnoauto\b@auto@" /etc/fstab

