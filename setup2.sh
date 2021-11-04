# https://github.com/CarlFK/pici/blob/main/setup2.sh

# netboot setup: server config and files to serve

# wget unzip mount raspi buster-lite.img

# create dirs for root and boot:
#  - img: only used for this script (loop devices are not stable over reboots)
#  - base: files copied from img
#  - setup: files added by this script
#  - updates: files changed by the pi (apt update/install etc.)

# restart services (doesn't work, so reboot)

set -ex

# where the files landed
fdir=${1:-$PWD/files}

apt install unzip kpartx nfs-kernel-server iptables squid-deb-proxy-client

cd ${fdir}
export http_proxy=$(/usr/share/squid-deb-proxy-client/apt-avahi-discover)
wget -N http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
unzip ${fdir}/2021-05-07-raspios-buster-armhf-lite.zip
kpartx -av 2021-05-07-raspios-buster-armhf-lite.img

cat ${fdir}/pxe/fstab >>/etc/fstab
cp ${fdir}/pxe/exports /etc

mkdir -p /srv/nfs/rpi/buster
cd /srv/nfs/rpi/buster

# pi boot
mkdir boot
cd boot
mkdir img base setup updates play work merged
mount /dev/mapper/loop0p1 img
rsync -xa --progress img/ base
umount img
cp ${fdir}/rpi/cmdline.txt setup
touch setup/ssh
mount /srv/nfs/rpi/buster/boot/merged
cd ..

# pi3 netboot is hardcoded to:
#  boot dhcpserver/bootcode.bin so it must be in tftp's root
#  and then the same root dir or /$serial/*
# Putting all the files in the tftp root is messy,
# so put them all under nfs and create links to them

ln -s /srv/nfs/rpi/buster/boot/merged/bootcode.bin /srv/tftp/bootcode.bin
ln -s /srv/nfs/rpi/buster/boot/merged/ /srv/tftp/f1b7bb5a
ln -s /srv/nfs/rpi/buster/boot/merged/ /srv/tftp/e0c074cd

# pi root fs
mkdir root
cd root
mkdir img base setup updates play work merged
mount /dev/mapper/loop0p2 img
rsync -xa --progress img/ base
umount img

cd setup

mkdir etc
cp ${fdir}/rpi/fstab etc/
cp ${fdir}/rpi/issue etc/

mkdir etc/default
cp ${fdir}/rpi/keyboard etc/default/

mkdir etc/ssh
ssh-keygen -A -f $PWD
mkdir -p root/.ssh
ssh-keygen -f root/.ssh/id_rsa -P score
mkdir -p home/pi/.ssh
ssh-keygen -f home/pi/.ssh/id_rsa -P score

# enable the service
mkdir -p etc/systemd/system
ln -s /lib/systemd/system/ssh.service etc/systemd/system/sshd.service

# not sure how to do the right.
# sudo cp config/ssh/authorized_keys /media/rootfs/root/.ssh/authorized_keys
# sudo cp config/ssh/authorized_keys /media/rootfs/home/${user}/.ssh/authorized_keys

cd ..
sudo chown -R --reference=base/home/pi setup/home/pi/.ssh

mount /srv/nfs/rpi/buster/root/merged
cd

cp ${fdir}/pxe/rpi.conf /etc/dnsmasq.d
chown root: /etc/dnsmasq.d/rpi.conf

systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

systemctl restart dnsmasq.service
# Some networking stuff doesn't restart right, reboot fixes it :/
reboot

