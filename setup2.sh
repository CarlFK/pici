# https://github.com/CarlFK/pici/blob/main/setup2.sh

# shuffle the files, start the services

set -ex

# where the extra files landed
fdir=${1:-/home/juser/files}

cp ${fdir}/pxe/rpi.conf /etc/dnsmasq.d
chown root: /etc/dnsmasq.d/rpi.conf

cat ${fdir}/pxe/fstab >>/etc/fstab
cp ${fdir}/pxe/exports /etc

mkdir -p /srv/nfs/rpi/buster
cd /srv/nfs/rpi/buster
unzip ${fdir}/2021-05-07-raspios-buster-armhf-lite.zip
kpartx -av 2021-05-07-raspios-buster-armhf-lite.img


# what the pi will boot
mkdir boot
cd boot
mkdir img lower upper work merged
mount /dev/mapper/loop0p1 img
cp img/bootcode.bin /srv/tftp
rsync -xa --progress img/ lower/
umount img
cp ${fdir}/rpi/cmdline.txt upper/
cp ${fdir}/rpi/ssh upper/
# mount -o ro -t overlay overlay -olowerdir=lower,upperdir=upper,workdir=work merged
mount /srv/nfs/rpi/buster/boot/merged
cd ..

# one link for each pi
ln -s /srv/nfs/rpi/buster/boot/merged/ /srv/tftp/f1b7bb5a
ln -s /srv/nfs/rpi/buster/boot/merged/ /srv/tftp/e0c074cd

# pi's root fs
mkdir root
cd root
mkdir img lower upper work merged
mount /dev/mapper/loop0p2 img
rsync -xa --progress img/ lower/
umount img
mkdir upper/etc
cp ${fdir}/rpi/fstab /srv/nfs/rpi/buster/root/upper/etc/
cp ${fdir}/rpi/issue /srv/nfs/rpi/buster/root/upper/etc/
cp ${fdir}/rpi/keyboard /srv/nfs/rpi/buster/root/upper/etc/
# mount -o ro -t overlay overlay -olowerdir=img,upperdir=upper,workdir=work merged
mount /srv/nfs/rpi/buster/root/merged
cd

systemctl restart dnsmasq.service
systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

# Some networking stuff isn't setup right, reboot fixes it :/
reboot

