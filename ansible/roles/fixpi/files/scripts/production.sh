#!/bin/bash
set -ex

# production.sh
# production mode.
# use to get out of maintenance mode.

# things it does:
# shutdown the maintenance pi
# nfs exports set to ro,
# pi overlay tmpfs,
# pi fstab: don't mount boot
# pi fstab: mount / ro

source /etc/environment.export

ssh pi@${mpi_ip} "sudo poweroff"
sleep 1

systemctl stop nfs-server.service

# clean up stuff that should not persist
# touch first to make sure there is something to rm

touch ${nfs_root}/var/lib/dhcp/dhclient.leases
rm ${nfs_root}/var/lib/dhcp/dhclient.leases

rm ${nfs_root}/var/log/journal/*/system.journal || true # if there is no file, don't error.

# turn on overlayroot
sed -i -E "/.*/s/overlayroot=(tmpfs)?/overlayroot=tmpfs/" ${nfs_boot}/cmdline.txt
# sed -i E 's/([[:blank:]]|^)overlayroot=[^[:blank:]]*/\1overlayroot=tmpfs/'  ${nfs_boot}/cmdline.txt

# cat ${nfs_boot}/cmdline.txt

# don't automount pi's /boot
# sed -i "/.boot.* nfs*/s/,auto,/,noauto,/" ${nfs_root}/etc/fstab
# pi fstab: mount / ro
# um.. where is it?

# take 2: use the sed from maintenance.sh...
# pi's fstab: (no sd) set nfs mounts / and /boot to noauto(mount),ro
sed -i "\@${nfs_pth}.*\snfs\s@s@\bauto\b@noauto@" ${nfs_root}/etc/fstab
sed -i "\@${nfs_pth}.*\snfs\s@s@\brw\b@ro@" ${nfs_root}/etc/fstab

# done with pi files, so ro all of them:
# make the nfs shares ro (read only)
sed -i "s/rw,/ro,/" /etc/exports

systemctl start nfs-server.service

cat ${nfs_boot}/cmdline.txt
cat ${nfs_root}/etc/fstab
cat /etc/exports

poe.sh ${mpi_port} 2
sleep 1
allpoe.sh 1
