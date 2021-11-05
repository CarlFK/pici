
mkdir -p /srv/nfs/x86/be
cd /srv/nfs/x86
debootstrap stable be
chroot be passwd
# bilibop-rules bilibop-rules/on-live-system boolean true
chroot be apt install bilibop

