#!/usr/bin/env bash

set -e
set -x

release="${release:=trixie}"
image_base="${image_base:-2025-12-04-raspios-${release}-armhf-lite.img}"
base_dir="${base_dir:-/srv/nfs/rpi}"
target="${target:-${base_dir}/${release}}"

# `exec /sbin/init` should pass control off to systemd, and it will boot as before
#
poe.sh 21 2
systemctl stop nfs-server.service

rm -rf "${target}"

./pici/ansible/roles/img/files/img2files.sh "/var/cache/pib/${image_base}.xz" "/var/cache/pib/${image_base}" "${release}"

for f in config.txt cmdline.txt; do
  cp "${f}" "${target}/boot"
done
cp fstab "${target}/root/etc/"
cp chroot.conf "${target}/root/etc/initramfs-tools/conf.d"

touch "${target}/boot/ssh"
cp userconf.txt "${target}/boot"
# touch "${target}/root/boot/firmware/ssh"
# cp userconf.txt "${target}/root/boot/firmware"

# rm "${target}/root/boot/firmware/ssh"
# cp user-data "${target}/root/boot/firmware"
# cp user-data "${target}/boot"

# rm ${target}/root/etc/init.d/resize2fs_once

divert="/var/lib/systemd/deb-systemd-helper-enabled/rpi-resize.service.dsh-also"
chroot "${target}/root" dpkg-divert --divert "${divert}.diverted" --rename "${divert}"

divert="/usr/lib/systemd/zram-generator.conf.d/20-rpi-swap-zram0-ctrl.conf"
chroot "${target}/root" dpkg-divert --divert "${divert}.diverted" --rename "${divert}"
divert="/usr/lib/systemd/system-generators/rpi-swap-generator"
chroot "${target}/root" dpkg-divert --divert "${divert}.diverted" --rename "${divert}"

for unit in \
    systemd-growfs@.service \
    systemd-growfs-root.service \
    rpi-remove-swap-file@.service \
    rpi-resize-swap-file.service \
    swap.target \
    rpi-resize.service
do
    systemctl --root "${target}/root/" mask "${unit}"
done

./chroot-mount-nfs.bash
chroot /mnt/target apt install -y nfs-common
umount --recursive --lazy /mnt/target

# find "${target}/root" -iname "*grow*" -or -iname "*resize*" -o -iname "*swap*" | grep system
# :%s[/srv/nfs/rpi/trixie/root/usr/lib/systemd/system/[[g

systemctl restart nfs-server.service
# poe.sh 21 1

# cat "${target}/boot/user-data"
echo nmap -p 22 10.21.0.121
