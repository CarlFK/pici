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

dist=buster
img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28
base_name=2021-05-07-raspios-buster-armhf-lite
zip_name=${base_name}.zip
img_name=${base_name}.img
user=pi

# dist=impish
# img_host=http://cdimage.ubuntu.com/releases/21.10/release
# img_name=ubuntu-21.10-preinstalled-server-armhf+raspi.img
# zip_name=${img_name}.xz
# user=ubuntu

# http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip


apt install unzip kpartx nfs-kernel-server iptables

cd ${fdir}
export http_proxy=http://pc8:8000/
wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
wget -N ${img_host}/${zip_name}
# unzip....
unzip -u ${zip_name}
# xz --keep -vv --decompress ${zip_name}
kpartx -av ${img_name}

cat ${fdir}/pxe/fstab >>/etc/fstab
cp ${fdir}/pxe/exports /etc

mkdir -p /srv/nfs/rpi/${dist}
cd /srv/nfs/rpi/${dist}

# pi boot
mkdir boot
cd boot
mkdir img base setup updates play work merged
mount /dev/mapper/loop0p1 img
rsync -xa --progress img/ base
umount img
cp ${fdir}/rpi/cmdline.txt setup
# cp ${fdir}/rpi/user-data setup
touch setup/ssh
# mount /srv/nfs/rpi/${dist}/boot/merged
cd ..

# pi3 netboot is hardcoded to:
#  boot dhcpserver/bootcode.bin so it must be in tftp's root
#  and then the same root dir or /$serial/*
# Putting all the files in the tftp root is messy,
# so put them all under nfs and create links to them

# ln -s /srv/nfs/rpi/buster/boot/merged/bootcode.bin /srv/tftp/bootcode.bin
# ln -s /srv/nfs/rpi/impish/boot/merged/boot.scr boot.scr.uimg

ln -sf /srv/nfs/rpi/${dist}/boot/merged/ /srv/tftp/f1b7bb5a
ln -sf /srv/nfs/rpi/${dist}/boot/merged/ /srv/tftp/e0c074cd

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

# Raspi is UK, Ubuntu is US
mkdir etc/default
cp ${fdir}/rpi/keyboard etc/default/

mkdir -p home/${user}
cp ${fdir}/rpi/setup3.sh home/${user}
cp ${fdir}/overlayroot_0.47ubuntu1_all.deb home/${user}

# Ubuntu cloud-init does this
# mkdir etc/ssh
# ssh-keygen -A -f $PWD
# mkdir -p root/.ssh
# ssh-keygen -f root/.ssh/id_rsa -P score


# enable the service
# mkdir -p etc/systemd/system
# ln -s /lib/systemd/system/ssh.service etc/systemd/system/sshd.service

# not sure how to do the right.
# cp config/ssh/authorized_keys /media/rootfs/root/.ssh/authorized_keys
# cp config/ssh/authorized_keys /media/rootfs/home/${user}/.ssh/authorized_keys
# cd ..
# cp ~/.ssh/id_rsa.pub setup/home/${user}/.ssh/authorized_keys

mkdir -p home/${user}/.ssh
ssh-keygen -f home/${user}/.ssh/id_rsa -P score
cd ..
chown -R --reference=base/home/${user} setup/home/${user}

# mount /srv/nfs/rpi/${dist}/root/merged
cd

cp ${fdir}/pxe/rpi.conf /etc/dnsmasq.d
chown root: /etc/dnsmasq.d/rpi.conf

systemctl enable rpcbind
systemctl restart rpcbind

systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

systemctl restart dnsmasq.service

# Some networking stuff doesn't restart right, reboot fixes it :/
echo sudo reboot

