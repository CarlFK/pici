#!/bin/bash -ex

mkdir overlayroot
cd overlayroot

wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
apt install --assume-yes ./overlayroot_0.47ubuntu1_all.deb

# generate (-c create) an initrd for the current kernel ver,
# the name will ...
KERN=$(uname -r)
update-initramfs -c -k "${KERN}"

# the name will be this:
INITRD=initrd.img-"${KERN}"

# remove any previous initramfs=
sed -i /boot/config.txt -e "/initramfs.*/d"
# add initramfs=initrd.img-5.4.321-go
echo initramfs "${INITRD}" >> /boot/config.txt
