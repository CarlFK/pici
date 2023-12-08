#!/bin/bash -ex

# uppi2.sh
# run on the pi

# really just installs overlayroot from Ubuntu's repo

# https://launchpad.net/cloud-initramfs-tools
# https://packages.ubuntu.com/kinetic/overlayroot
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
Pi setup is all done and ready for production:
server:
files/scripts/normal.sh

powercycel the pi.
turn them all on!

uppi2.sh says bye bye!
EOT
poweroff
