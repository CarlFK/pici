# setup the server
# nfs, host the root fs (boot is on local storage)

apt install nfs-kernel-server
# etc/exports:
# /srv/nfs/x86/be *(ro,sync,no_subtree_check,no_root_squash,fsid=3)

mkdir -p /srv/nfs/x86/be
cd /srv/nfs/x86
debootstrap stable be
chroot be passwd
# bilibop-rules bilibop-rules/on-live-system boolean true
chroot be apt install bilibop

systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

