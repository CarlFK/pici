#!/bin/bash
set -ex

# maintenance.sh
# give pi's (all of them) rw access to the nfs shares, mount /boot

dist=bullseye
p=/srv/nfs/rpi/${dist}
boot=${p}/boot
root=${p}/root

# pi overlayroot off
sed -i "/.*/s/overlayroot=tmpfs/overlayroot=/" ${boot}/cmdline.txt

# pi fstab: automount,rw / and /boot
sed -i "\@${p}.*\snfs\s@s@\bnoauto\b@auto@" ${root}/etc/fstab
sed -i "\@${p}.*\snfs\s@s@\bro\b@rw@" ${root}/etc/fstab

# server nfs shares rw
sed -i "/.*/s/ro,/rw,/" /etc/exports
systemctl restart nfs-server.service

