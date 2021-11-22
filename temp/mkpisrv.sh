#!/bin/bash -ex

# edit cmdline.txt, replace my IP with your IP, put it in your pi's boot.
cat <<EOT >> cmdline.txt
root=/dev/nfs nfsroot=192.168.1.119:/srv/nfs/pi/root,vers=4.1 rw ip=dhcp rootwait elevator=deadline consoleblank=0 overlayroot=tmpfs,debug=1
EOT
ip r>> cmdline.txt

apt install nfs-kernel-server unzip kpartx dcfldd

img_host=http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/
base_name=2021-10-30-raspios-bullseye-armhf-lite
zip_name=${base_name}.zip
img_name=${base_name}.img

wget -N ${img_host}/${zip_name}
unzip -u ${zip_name}
# burn to sd
echo sudo dcfldd if=${img_name} of=/dev/sdb
kpartx -av ${img_name}
mkdir img2
mount /dev/mapper/loop0p2 img2

mkdir -p /srv/nfs/pi/root
rsync -xa --progress img2/ /srv/nfs/pi/root
umount img2

cat <<EOT >> /etc/exports
/srv/nfs/pi/root *(rw,sync,no_subtree_check,no_root_squash)
EOT
systemctl restart nfs-kernel-server

