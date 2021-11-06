#!/bin/bash -ex

# set up client and server to demo overlayroo and bilibop
# client is a debian or ubuntu box with grub and /boot/ to boot a kernel
# kernel mounts nfs on /

# negk: nfs server
# gator: local boot, nfs client (debian w/sshd)

# You will need to find these, put them here so they can be sent to client
# I got them from a Ubuntu install.
# vmlinuz-5.4.0-89-generic
# initrd.img-5.4.0-89-generic
rsync -rtvP 40_custom vmlinuz* initrd* juser@gator:
# Config client to use it:
ssh juser@gator
# on gator:
# put Ubuntu kernele in /boot
sudo cp vmlinuz* initrd* /boot/
# add debian and ubuntu on nfs to grub
sudo cp 40_custom /etc/grub.d/;sudo update-grub;sudo reboot

# At this poing the local install should still work,
# the 2 new options should kernel panic.

# Set up the server

# on Server:
apt install nfs-kernel-server
mkdir -p /srv/nfs/x86/bullseye /srv/nfs/x86/focal
# etc/exports:
# /srv/nfs/x86/bullseye *(ro,sync,no_subtree_check,no_root_squash,fsid=3)
# /srv/nfs/x86/focal *(ro,sync,no_subtree_check,no_root_squash,fsid=4)
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

cd /srv/nfs/x86
debootstrap stable bullseye
debootstrap focal focal http://archive.ubuntu.com/ubuntu/

# server ready to test.
# before you set the root passwords,
# boot client, make sure the 2 local/nfs items don't kernel panic.

# set root password and install things
chroot bullseye passwd
chroot focal passwd

# bilibop-rules bilibop-rules/on-live-system boolean true
chroot bullseye apt install bilibop
# lockfs is already in place (see 40_custom)

chroot focal apt install overlayroot
cp ${OLDPWD}/overlayroot.conf /srv/nfs/x86/focal/etc

# boot the clients - focal has a rw ram fs on top of rw nfs.
# bullseye ... no change.

exit

# samples of what / is mounted on:

# success!
juser@negk:~$ findmnt /
TARGET SOURCE      FSTYPE OPTIONS
/      overlayroot overla rw,relatime,lowerdir=/media/root-ro,upperdir=/media/r

# not succuss :(
$ findmnt /
TARGET SOURCE                              FSTYPE OPTIONS
/      192.168.1.121:/srv/nfs/x86/bullseye nfs    rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,nolock,proto=tcp,port=2049,timeo=600,retrans=10,sec=sys,local_lock=all,addr=192.168.1.121
$ cat /proc/cmdline
BOOT_IMAGE=/vmlinuz-5.10.0-9-amd64 root=/dev/nfs nfsroot=192.168.1.121:/srv/nfs/x86/bullseye rw lockfs

# plain old disk:
root@negk:/srv/nfs/x86# findmnt /
TARGET SOURCE                    FSTYPE OPTIONS
/      /dev/mapper/negk--vg-root ext4   rw,relatime,errors=remount-ro

