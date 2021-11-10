#!/bin/bash -ex

# edit cmdline.txt, replace my IP with your IP, put it in your pi's boot.
cat <<EOT >> cmdline.txt
root=/dev/nfs nfsroot=192.168.1.119:/srv/nfs/pi/root,vers=4.1 rw ip=dhcp rootwait elevator=deadline consoleblank=0 overlayroot=tmpfs,debug=1
EOT
ip r>> cmdline.txt

apt install nfs-kernel-server unzip kpartx dcfldd

img_host=http://raspi.debian.net/daily
base_name=raspi_4_bullseye
zip_name=${base_name}.img.xz
img_name=${base_name}.img

# img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28
# base_name=2021-05-07-raspios-buster-armhf-lite
# zip_name=${base_name}.zip
# img_name=${base_name}.img

export http_proxy=http://pc8:8000/
wget -N ${img_host}/${zip_name}
# unzip -u ${zip_name}
xz --keep -vv --decompress ${zip_name}
echo sudo dcfldd if=${img_name} of=/dev/sdb
kpartx -av ${img_name}
mkdir img2
mount /dev/mapper/loop0p2 img2

mkdir -p /srv/nfs/pi/root
rsync -xa --progress img2/ /srv/nfs/pi/root
umount img2

wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
cp overlayroot_0.47ubuntu1_all.deb /srv/nfs/pi/root/home/pi

cat <<EOT >> /etc/exports
/srv/nfs/pi/root *(rw,sync,no_subtree_check,no_root_squash)
EOT
systemctl restart nfs-kernel-server

