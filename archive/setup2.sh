#!/bin/bash
# https://github.com/CarlFK/pici/blob/main/setup2.sh

# netboot setup: server config and files to serve

# wget unzip mount raspi buster-lite.img

# create dirs for boot and root:
# copy files from .img, tweek to make netbootable, export, use a pi client to apt update and install more things.

set -ex

# where the files landed
fdir=${1:-$PWD/files}

# where to get an img file:
img_host=http://downloads.raspberrypi.org
img_path=raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07
base_name=2022-04-04-raspios-bullseye-armhf-lite
zip_name=${base_name}.img.xz
img_name=${base_name}.img
user=pi
dist=bullseye

# trunk of nfs things
d=/srv/nfs/rpi/${dist}

apt install -y unzip nfs-kernel-server nftables iptables pwgen whois snmp parted

cp ${fdir}/pxe/nftables.conf /etc
systemctl restart nftables.service

printf "\nhost=10.21.0.1\n" >> /etc/default/nfs-kernel-server

cd ${fdir}

# get the image file:
wget -N ${img_host}/${img_path}/${zip_name}
# unzip -u ${zip_name# }
xz --keep --decompress ${zip_name} | true
# kpartx -av ${img_name}
losetup -P /dev/loop5 ${img_name}
partprobe
mkdir -p /tmp/img

# extract files from image to server's fs
mkdir -p ${d}
(cd ${d}

# pi's boot dir (normally SD's first partition)
mkdir boot
mount /dev/loop5p1 /tmp/img
rsync -xa --progress /tmp/img/ boot
umount /tmp/img

# enable sshd
touch boot/ssh

cp boot/cmdline.txt boot/cmdline.org
cp ${fdir}/rpi/cmdline.txt boot/

cp boot/config.txt boot/config.org
cp ${fdir}/rpi/config.txt boot/

# pi3 netboot is hardcoded to:
#  boot dhcpserver/bootcode.bin so it must be in tftp's root
#  and then the same root dir or /$serial/*
# Putting all the files in the tftp root is messy,
# so put them all under nfs and create links to them

ln -s ${d}/boot/bootcode.bin /srv/tftp/bootcode.bin

# some pi serial numbers:
for id in e897e1d3 f1b7bb5a e0c074cd 6807ce11 d2cb1ff7 7a6d27f6 80863963 329205c6; do
    ln -s ${d}/boot/ /srv/tftp/${id}
done

# pi root fs
mkdir root

mount /dev/loop5p2 /tmp/img
rsync -xa --progress /tmp/img/ root
umount /tmp/img

losetup -d /dev/loop5

# tell pi where boot is
cp ${fdir}/rpi/fstab root/etc/

# show IP and other useful stuff on console before login
cp ${fdir}/rpi/issue root/etc/

# generate a random password for pi user
pass=$(pwgen)
printf "%s\n" ${pass} >>  root/etc/issue
printf "%s\n" ${pass} > root/etc/ssh/password.txt
cp ${fdir}/rpi/password.conf root/etc/ssh/sshd_config.d/
# crypt_pass=$(mkpasswd ${pass})
# usermod --root $PWD/root/ --password ${crypt_pass} ${user}
# useradd --root $PWD/root/ --password ${crypt_pass} ${user}

# echo 'mypassword' | openssl passwd -6 -stdin
crypt_pas=$(openssl passwd -6 env:pass)
printf "%s:%s" ${user} ${crypt_pas} > boot/userconf.txt

# skip trying to resize the root fs
rm root/etc/rc3.d/S01resize2fs_once root/etc/init.d/resize2fs_once

# don't try to manage a swap file
rm root/etc/systemd/system/multi-user.target.wants/dphys-swapfile.service

# avoid this error: [FAILED] Failed to start Set console font and keymap.
rm root/etc/systemd/system/multi-user.target.wants/console-setup.service

# get rid of: Wi-Fi is currently blocked by rfkill.
rm root/etc/profile.d/wifi-check.sh

# [FAILED] Failed to start Hostname Service.
# See 'systemctl status systemd-hostnamed.service' for details.
# FIXME

# Raspi is UK, Ubuntu and Debian are US
cp ${fdir}/rpi/keyboard root/etc/default/

cp ${fdir}/rpi/show_info.sh root/etc/profile.d/

# things that maybe could be done here but it is easer to run them on the pi
cp ${fdir}/rpi/setup3.sh root/root

mkdir root/home/${user}/bin/
# script to stream the cam
cp ${fdir}/rpi/cam.sh root/home/${user}/bin/

)

# show on server where the stuff is
echo <<EOT >/etc/profile.d/show_pidirs.sh
echo ${d}/boot
echo ${d}/root
EOT


cp ${fdir}/pxe/exports /etc

systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

cp ${fdir}/pxe/rpi.conf /etc/dnsmasq.d
chown root: /etc/dnsmasq.d/rpi.conf
systemctl restart dnsmasq.service
# Some networking stuff doesn't restart right, reboot fixes it :/

${fdir}/scripts/maintenance.sh
echo "boot a pi, sudo -i, ./setup3.sh"
