#!/bin/bash -x

# burn down the server
# rebuild with setup2.sh

dist=bullseye
p=/srv/nfs/rpi/${dist}

systemctl stop nfs-server.service

umount ${p}/boot/merged
umount ${p}/root/merged

find /srv/tftp -type l -delete
rm -rf ${p}

# remove our overlay lines from fstab and exports
sed -i "\@overlay\s*${p}/[br]oot/merged@d" /etc/fstab
sed -i "\@^${p}/[br]oot/merged@d" /etc/exports

# remove the host= line (leave the [nfsd], seems better?
# printf "\n[nfsd]\nhost=10.21.0.1\n" >> /etc/default/nfs-kernel-server
sed -i "\@^host=10.21.0.1@d" /etc/default/nfs-kernel-server

