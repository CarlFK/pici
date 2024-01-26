#!/bin/bash -ex

# mount sdcard's p1 (boot) and p2 (/ root)
# ./fixit.sh user password [/path/to/rootfs] [/path/to/bootfs]

user=$1
password=$2

mntdir=/media/${USER}
rootfs=${3:-${mntdir}/rootfs}
bootfs=${4:-${mntdir}/bootfs}

# ansible roles (where some handy stuff lives)
aroles=../../ansible/roles

# sanity checks to make sure the image is mounted where we say it is.
if  [ ! -d "${aroles}/fixpi" ]; then
    echo "${aroles}/fixpi does not exist."
    exit
fi

if  [ ! -d "${rootfs}/root/" ]; then
    echo ${rootfs}/root/ does not exist.
    exit
fi

# define user/password
# pre-seed raspios's "make a new user" process
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
crypt_pas=$(echo ${password} | openssl passwd -6 -stdin)
printf "%s:%s" ${user} ${crypt_pas} > ${bootfs}/userconf.txt

# enable ssh,
sudo touch ${bootfs}/ssh

# show IP and other stuff on console
sudo cp ${aroles}/fixpi/files/etc/issue ${rootfs}/etc/

sudo cp ${aroles}/fixpi/files/etc/keyboard ${rootfs}/etc/default/keyboard

sudo mkdir -p ${rootfs}/root/.ssh
# sudo ssh-keygen -f root/.ssh/id_rsa

# cp keys from local user
sudo cp ~/.ssh/id_rsa.pub ${rootfs}/root/.ssh/authorized_keys
sudo chown -R --reference=${rootfs}/root ${rootfs}/root/.ssh
