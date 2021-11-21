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

dist=bullseye

img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/
base_name=2021-10-30-raspios-bullseye-armhf-lite
zip_name=${base_name}.zip
img_name=${base_name}.img
user=pi

# img_host=http://raspi.debian.net/daily
# base_name=raspi_4_bullseye

# img_host=http://raspi.debian.net/tested
# base_name=20210823_raspi_4_bullseye

# zip_name=${base_name}.img.xz
# img_name=${base_name}.img
# user=pi

# img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28
# base_name=2021-05-07-raspios-buster-armhf-lite
# zip_name=${base_name}.zip
# img_name=${base_name}.img
# user=pi

# dist=impish
# img_host=http://cdimage.ubuntu.com/releases/21.10/release
# img_name=ubuntu-21.10-preinstalled-server-armhf+raspi.img
# zip_name=${img_name}.xz
# user=ubuntu

apt install unzip kpartx nfs-kernel-server iptables

# get the image file:
cd ${fdir}

export http_proxy=http://pc8:8000/
wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
wget -N ${img_host}/${zip_name}

# if zip is newer, decompress
# -ot True if file1 is older than file2, or if file2 exists and file1 does not.
if [[ ${img_name} -ot ${zip_name} ]]; then
    # unzip -u ${zip_name}
    xz --keep -vv --decompress --force ${zip_name}
fi
kpartx -av ${img_name}

# move files from image to server's fs
# trunk of nfs things
d=/srv/nfs/rpi/${dist}
mkdir -p ${d}
(cd ${d}

# pi's boot dir (normally SD's first partition)
mkdir boot
(cd boot
mkdir img base setup updates play work merged
mount /dev/mapper/loop0p1 img
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

# ln -s /srv/nfs/rpi/buster/boot/merged/bootcode.bin /srv/tftp/bootcode.bin
# ln -s /srv/nfs/rpi/impish/boot/merged/boot.scr boot.scr.uimg

# pi serial numbers we are booting:
for id in f1b7bb5a e0c074cd; do
    ln -sf ${d}/boot/merged/ /srv/tftp/${id}
done

# pi root fs
mkdir root
(cd root
mkdir img base setup updates play work merged

mount /dev/mapper/loop0p2 img
rsync -xa --progress img/ base
umount img
kpartx -d ${fdir}/${img_name}

p=${d}/root
mount -t overlay overlay -o \
lowerdir=${p}/base,\
upperdir=${p}/setup,\
workdir=${p}/work \
    ${p}/merged

(cd merged

# because debian can't nfs mount boot/firmware/
# cp ${fdir}/rpi/sysconf.txt boot/firmware/
# cp ${fdir}/rpi/blacklist.conf etc/modprobe.d/

cp ${fdir}/rpi/fstab etc/
cp ${fdir}/rpi/issue etc/
cp ${fdir}/rpi/30autoproxy etc/apt/apt.conf.d/
rm etc/rc3.d/S01resize2fs_once
rm etc/init.d/resize2fs_once
rm etc/systemd/system/multi-user.target.wants/dphys-swapfile.service

# Raspi is UK, Ubuntu and Debian are US
cp ${fdir}/rpi/keyboard etc/default/

# cmdline_custom="/etc/default/raspi-extra-cmdline"
echo "root=/dev/nfs nfsroot=10.21.0.1:/srv/nfs/rpi/bullseye/root/merged" > etc/default/raspi-extra-cmdline

# prevent /boot/firmware/sysconf.txt from being re-written
# unlink requires etc/systemd/system/basic.target.requires/rpi-set-sysconf.service
# rm etc/systemd/system/sysinit.target.requires/rpi-reconfigure-raspi-firmware.service
# rm etc/systemd/system/multi-user.target.requires/rpi-reconfigure-raspi-firmware.service
# rm etc/systemd/system/basic.target.requires/rpi-set-sysconf.service
rm etc/systemd/system/multi-user.target.wants/console-setup.service

cp ${fdir}/rpi/setup3.sh root
cp ${fdir}/overlayroot_0.47ubuntu1_all.deb root

echo >>home/pi/.bashrc <<EOT
cat /proc/cmdline
findmnt /
EOT

# mkdir etc/ssh
# ssh-keygen -A -f $PWD
# mkdir -p root/.ssh
# ssh-keygen -f root/.ssh/id_rsa -P score

# enable the service
# mkdir -p etc/systemd/system
# ln -s /lib/systemd/system/ssh.service etc/systemd/system/sshd.service

# not sure how to do this right.
# cp config/ssh/authorized_keys /media/rootfs/root/.ssh/authorized_keys
# cp config/ssh/authorized_keys /media/rootfs/home/${user}/.ssh/authorized_keys
# cd ..
# cp ~/.ssh/id_rsa.pub setup/home/${user}/.ssh/authorized_keys

# mkdir -p home/${user}/.ssh
# ssh-keygen -f home/${user}/.ssh/id_rsa -P score
# cd ..
# chown -R --reference=base/home/${user} setup/home/${user}

)
umount merged
)
)

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
echo sudo reboot
echo sudo files/scripts/updates_on.sh
