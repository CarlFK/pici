#!/bin/bash
# https://github.com/CarlFK/pici/blob/main/setup2.sh

# netboot setup: server config and files to serve

# wget unzip mount raspi buster-lite.img

# create dirs for boot and root:
#  - img: only used for this script (loop devices are not stable over reboots)
#  - base: files copied from img
#  - setup: files added by this script
#  - updates: files changed by the pi (apt update/install etc.)
#  - play: files changed by the pi for experiments

# restart services (sometimes doesn't work, so reboot)

set -ex

# where the files landed
fdir=${1:-$PWD/files}

img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/
base_name=2021-10-30-raspios-bullseye-armhf-lite
zip_name=${base_name}.zip
img_name=${base_name}.img
user=pi
dist=bullseye

# trunk of nfs things
d=/srv/nfs/rpi/${dist}

apt install unzip nfs-kernel-server iptables snmp

printf "\n[nfsd]\nhost=10.21.0.1\n" >> /etc/default/nfs-kernel-server

cd ${fdir}

# get the image file:
wget -N ${img_host}/${zip_name}
unzip -u ${zip_name}
# kpartx -av ${img_name}
losetup -P /dev/loop5 ${img_name}
partprobe

# extract files from image to server's fs
mkdir -p ${d}
(cd ${d}

# pi's boot dir (normally SD's first partition)
mkdir boot
(cd boot
mkdir img base setup updates play work merged
mount /dev/loop5p1 img
rsync -xa --progress img/ base
umount img

p=${d}/boot
mount -t overlay overlay -o \
lowerdir=${p}/base,\
upperdir=${p}/setup,\
workdir=${p}/work \
    ${p}/merged

(cd merged
touch ssh
cp ${fdir}/rpi/cmdline.txt .
cp ${fdir}/rpi/config.txt .
# cp ${fdir}/rpi/sysconf.txt .
# cp ${fdir}/rpi/user-data .
)
umount merged
)

# pi3 netboot is hardcoded to:
#  boot dhcpserver/bootcode.bin so it must be in tftp's root
#  and then the same root dir or /$serial/*
# Putting all the files in the tftp root is messy,
# so put them all under nfs and create links to them

ln -s ${d}/boot/merged/bootcode.bin /srv/tftp/bootcode.bin

# pi serial numbers:
for id in f1b7bb5a e0c074cd 6807ce11 d2cb1ff7 7a6d27f6; do
    ln -s ${d}/boot/merged/ /srv/tftp/${id}
done

# pi root fs
mkdir root
(cd root
mkdir img base setup updates play work merged

mount /dev/loop5p2 img
rsync -xa --progress img/ base
umount img

p=${d}/root
mount -t overlay overlay -o \
lowerdir=${p}/base,\
upperdir=${p}/setup,\
workdir=${p}/work \
    ${p}/merged

(cd merged

# tell pi where boot is (needed to build overlayroot's initrd)
cp ${fdir}/rpi/fstab etc/

# show IP and other useful stuff on console before login
cp ${fdir}/rpi/issue etc/

# skip trying to resize the root fs
rm etc/rc3.d/S01resize2fs_once etc/init.d/resize2fs_once

# don't try to manage a swap file
rm etc/systemd/system/multi-user.target.wants/dphys-swapfile.service

# avoid this error: [FAILED] Failed to start Set console font and keymap.
rm etc/systemd/system/multi-user.target.wants/console-setup.service

# [FAILED] Failed to start Hostname Service.
# See 'systemctl status systemd-hostnamed.service' for details.

# Raspi is UK, Ubuntu and Debian are US
cp ${fdir}/rpi/keyboard etc/default/

# things that maybe could be done here but it is easer to run them on the pi
cp ${fdir}/rpi/setup3.sh root
)
umount merged
)
)

losetup -d /dev/loop5

cat ${fdir}/pxe/fstab >>/etc/fstab

cp ${fdir}/pxe/exports /etc

cp ${fdir}/pxe/rpi.conf /etc/dnsmasq.d
chown root: /etc/dnsmasq.d/rpi.conf

systemctl enable rpcbind
systemctl restart rpcbind

systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

systemctl restart dnsmasq.service
# Some networking stuff doesn't restart right, reboot fixes it :/

echo "files/scripts/updates_on.sh;files/scripts/maintenance.sh"
