#!/bin/bash -ex

# mount -o remount,rw /
# passwd pi
# `exec /sbin/init` should pass control off to systemd, and it will boot as before
#
poe.sh 21 2
systemctl stop nfs-server.service

export d=trixie

rm -rf /srv/nfs/rpi/${d}

./pici/ansible/roles/img/files/img2files.sh /var/cache/pib/2025-12-04-raspios-trixie-armhf-lite.img.xz /var/cache/pib/2025-12-04-raspios-trixie-armhf-lite.img trixie

cp config.txt /srv/nfs/rpi/${d}/boot
cp cmdline.txt /srv/nfs/rpi/${d}/boot
cp fstab /srv/nfs/rpi/${d}/root/etc

# touch /srv/nfs/rpi/${d}/root/boot/firmware/ssh
# rm /srv/nfs/rpi/${d}/root/boot/firmware/ssh
cp user-data /srv/nfs/rpi/${d}/root/boot/firmware

# rm /srv/nfs/rpi/${d}/root/etc/init.d/resize2fs_once

rm /srv/nfs/rpi/${d}/root/var/lib/systemd/deb-systemd-helper-enabled/rpi-resize.service.dsh-also

rm /srv/nfs/rpi/${d}/root/usr/lib/systemd/zram-generator.conf.d/20-rpi-swap-zram0-ctrl.conf
rm /srv/nfs/rpi/${d}/root/usr/lib/systemd/system-generators/rpi-swap-generator

(
cd /srv/nfs/rpi/${d}/root/usr/lib/systemd/system
rm \
    systemd-growfs@.service \
    systemd-growfs-root.service \
    rpi-remove-swap-file@.service \
    rpi-resize-swap-file.service \
    swap.target \
    rpi-resize.service \
)

find /srv/nfs/rpi/${d}/root -iname "*grow*" -or -iname "*resize*" -o -iname "*swap*" |grep system
# :%s[/srv/nfs/rpi/trixie/root/usr/lib/systemd/system/[[g

systemctl restart nfs-server.service

nmap -p 22 10.21.0.121
systemctl restart nfs-server.service
poe.sh 21 1

cat /srv/nfs/rpi/${d}/root/boot/firmware/user-data
echo nmap -p 22 10.21.0.121
