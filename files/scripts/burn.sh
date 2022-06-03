#!/bin/bash -x

# burn down the pi boot files
# rebuild with:
#  ansible
#  maintenance.sh
#  boot a pi, run setup3.sh
# then
#  normal.sh

dist=bullseye
p=/srv/nfs/rpi/${dist}

systemctl stop nfs-server.service

# remove the tftp symlinks from /$serial/ to nfs/.../boot
find /srv/tftp -type l -delete
rm -rf ${p}

# remove our overlay lines from fstab and exports
sed -i "\@overlay\s*${p}/[br]oot@d" /etc/fstab
sed -i "\@^${p}/[br]oot@d" /etc/exports

# remove the host= line
sed -i "\@^host=10.21.0.1@d" /etc/default/nfs-kernel-server

