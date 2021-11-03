# netboot setup: simple nfs-server to help debug

set -ex

# where the files landed
fdir=${1:-$PWD/files}

apt install unzip kpartx nfs-kernel-server

cp ${fdir}/pxe/exports /etc

cd ${fdir}
wget -N http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
unzip ${fdir}/2021-05-07-raspios-buster-armhf-lite.zip
kpartx -av 2021-05-07-raspios-buster-armhf-lite.img

mkdir -p /srv/nfs/rpi/buster/
cd /srv/nfs/rpi/buster

# /etc/exports has this dir, so create it else the server won't start
mkdir -p boot/merged

# pi root fs
mkdir root
cd root
mkdir img merged
# copy files from the pi sd image to a dir that can be shared over nfs
mount /dev/mapper/loop0p2 img
rsync -xa --progress img/ merged
umount img

# tweeks to make it easier to work with
cd merged

# use US keyboard so the | key works
cp ${fdir}/rpi/keyboard etc/default/
# show IP on console
cp ${fdir}/rpi/issue etc/

ssh-keygen -A -f $PWD
mkdir -p root/.ssh
ssh-keygen -f root/.ssh/id_rsa -P score
mkdir -p home/pi/.ssh
ssh-keygen -f home/pi/.ssh/id_rsa -P score

# enable the sshd service (on the pi when it boots)
ln -s /lib/systemd/system/ssh.service etc/systemd/system/sshd.service

systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server
