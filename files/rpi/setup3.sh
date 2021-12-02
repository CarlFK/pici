#!/bin/bash -ex

# setup3.sh
# run on the pi

apt update --allow-releaseinfo-change
apt upgrade --assume-yes

apt install --assume-yes ssh-import-id vim tmux \
    git etckeeper sshfs tio rsync openocd fxload

apt autoremove --assume-yes

# E: Package 'sftp' has no installation candidate
# E: Unable to locate package flterm

# flcli=makestuff/apps/flcli/lin.x64/rel/flcli
# fx2loader=makestuff/apps/fx2loader/lin.x64/rel/fx2loader


wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
apt install --assume-yes ./overlayroot_0.47ubuntu1_all.deb

KERN=$(uname -r)
update-initramfs -c -k "${KERN}"

sed -i /boot/config.txt -e "/initramfs.*/d"
INITRD=initrd.img-"${KERN}"
echo initramfs "${INITRD}" >> /boot/config.txt

cat <<EOT
pi:
poweroff
server:
files/scripts/normal.sh
EOT
