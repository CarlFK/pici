#!/bin/bash -ex

# setup3.sh
# run on the pi

apt update --allow-releaseinfo-change
apt upgrade --assume-yes

apt install --assume-yes ssh-import-id vim tmux \
    git etckeeper sshfs tio rsync openocd fxload

# E: Package 'sftp' has no installation candidate
# E: Unable to locate package flterm

# flcli=makestuff/apps/flcli/lin.x64/rel/flcli
# fx2loader=makestuff/apps/fx2loader/lin.x64/rel/fx2loader

apt autoremove --assume-yes

wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
apt install --assume-yes ./overlayroot_0.47ubuntu1_all.deb

KERN=$(uname -r)
update-initramfs -c -k "${KERN}"

INITRD=initrd.img-"${KERN}"
sed -i /boot/config.txt -e "/initramfs.*/d"
echo initramfs "${INITRD}" >> /boot/config.txt

# because we now have an initrd, and:
# initramfs-tools: NFSv4 not supported for root fs
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=409271
# remove ,nfsvers=4,proto=tcp from cmdline.txt
# sed -i "/nfsroot/s/,nfsvers=.*proto=tcp//" /boot/cmdline.txt
sed -i "/nfsroot/s/,nfsvers=4.2//" /boot/cmdline.txt


cat <<EOT
server:
files/scripts/normal.sh

rpi/setup3.sh says bye bye!
EOT
poweroff
