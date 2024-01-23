#!/bin/bash -ex
# generate a random password for pi user
# usage: pipw.sh username [password] [rootfs] [bootfs]

user=${1:-pi}

# if [ "$#" -eq 2 ]; then
#    pass=$2
#else
#    # generate a default password
#    pass=$(pwgen --ambiguous)
#fi

# generate a default password
pass=$(pwgen --ambiguous)
pass=${2:-${$pass}}

# TODO figure out good defaults for these 3 cases:
# 1. on a booted pi: p1(boot) is mounted under /boot/firmware, p2(root) /
# 1a. seems like the case for defaults
# 2. on a flasher: p1 /media/carl/bootfs, p2 /media/carl/rootfs
# 2a. run from fixit.sh, so no need for defaults
# 3. on the netboot server, p1 /srv/nfs/rpi/bookworm/boot, p2 .../root
# 3a. run by ansible, so no need for defaults

# path to p1 (where to put userconf.txt)
bootfs=${3:-/boot/firmware}

# path to p2 (where to find etc/)
rootfs=${4:-/}

# save it in the clear so everyone can see it when they want to root the box
# note: this file is used by openssl passwd so don't mess it up
# we will find out if the \n messes it up
# seems \n is fine.
printf "%s\n" ${pass} > ${rootfs}/etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s %s\n" ${user} ${pass} >> ${rootfs}/etc/issue

# pre-seed raspios's "make a new user" process
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
crypt_pas=$(openssl passwd -6 -in ${rootfs}/etc/ssh/password.txt)
# this works for fixit.sh,
# fname=boot/firmware/userconf.txt
# this is for for ansible:
# fname=../boot/userconf.txt
fname=${bootfs}/userconf.txt
printf "%s:%s" ${user} ${crypt_pas} > ${fname}

# this sets the password of an existing user
# from back when raspios came with a user
# or maybe now to reset a password?
# crypt_pass=$(mkpasswd ${pass})
# usermod --root ${rootfs} --password ${crypt_pass} ${user}

