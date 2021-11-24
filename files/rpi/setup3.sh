#!/bin/bash -ex

# setup3.sh
# run on the pi

apt update --allow-releaseinfo-change
apt upgrade --assume-yes

apt install ssh-import-id

wget -N http://launchpadlibrarian.net/493868580/overlayroot_0.47ubuntu1_all.deb
apt install --assume-yes ./overlayroot_0.47ubuntu1_all.deb

KERN=$(uname -r)
update-initramfs -c -k "$KERN"

sed -i /boot/config.txt -e "/initramfs.*/d"
INITRD=initrd.img-"$KERN"
echo initramfs "$INITRD" >> /boot/config.txt

echo <<EOT
On the server:
  /etc/exports turn off rw,
  cmdline.txt - remove vers=4.1
EOT
