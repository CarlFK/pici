
kpartx -av 2020-05-27-raspios-buster-lite-armhf.img
mount /dev/mapper/loop0p1 boot
mount /dev/mapper/loop0p2 root

mkdir -p /srv/tftp/e0c074cd /srv/nfs/rpi/root

cp boot/bootcode.bin /srv/tftp
cp boot/* /srv/tftp/e0c074cd
cp -R root/* /srv/nfs/rpi/root/

mv cmdline.txt /srv/tftp/e0c074cd
mv fstab /srv/nfs/rpi/root/etc/
mv rpi.conf /etc/dnsmasq.d
mv exports /etc

chown root: /etc/dnsmasq.d/rpi.conf
systemctl restart dnsmasq.service

systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

# reboot

