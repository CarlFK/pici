#!/bin/bash
set -ex

# production.sh
# production mode.
# use to get out of maintenance mode.

# things it does:
# nfs exports set to ro,
# pi overlay tmpfs,
# pi fstab: don't mount boot
# pi fstab: mount / ro

dist=bookworm
p=/srv/nfs/rpi/${dist}
boot=${p}/boot
root=${p}/root

systemctl stop nfs-server.service

# clean up stuff that should not persist
# touch first to make sure there is something to rm
touch ${root}/var/lib/dhcp/dhclient.leases
rm ${root}/var/lib/dhcp/dhclient.leases

# turn on overlayroot
sed -i -E "/.*/s/overlayroot=(tmpfs)?/overlayroot=tmpfs/" ${boot}/cmdline.txt
# sed -i E 's/([[:blank:]]|^)overlayroot=[^[:blank:]]*/\1overlayroot=tmpfs/'  ${boot}/cmdline.txt

cat ${boot}/cmdline.txt

# don't automount pi's /boot
# sed -i "/.boot.* nfs*/s/,auto,/,noauto,/" ${root}/etc/fstab
# pi fstab: mount / ro
# um.. where is it?

# take 2: use the sed from maintenance.sh...
# pi's fstab: (no sd) set nfs mounts / and /boot to noauto(mount),ro
sed -i "\@${p}.*\snfs\s@s@\bauto\b@noauto@" ${root}/etc/fstab
sed -i "\@${p}.*\snfs\s@s@\brw\b@ro@" ${root}/etc/fstab

# done with pi files, so ro all of them:
# make the nfs shares ro (read only)
sed -i "s/rw,/ro,/" /etc/exports

systemctl start nfs-server.service

cat ${boot}/cmdline.txt
cat ${root}/etc/fstab
cat /etc/exports
