#!/bin/bash -ex
# generate a random password for pi user
# usage: pipw.sh username [password] [rootfs] [bootfs]

user=${1:-pi}

if [ "$#" -ge 2 ]; then
    pass=$2
else
    # generate a default password
    pass=$(pwgen --ambiguous)
fi

# path to p1 (where to put userconf.txt)
bootfs=${3:-/boot/firmware}

# path to p2 (where to find etc/)
rootfs=${4:-/}

# save it in the clear so everyone can see it when they want to root the box
# note: this file is used by openssl passwd below, so don't mess this up
printf "%s\n" ${pass} > ${rootfs}/etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s %s\n" ${user} ${pass} >> ${rootfs}/etc/issue

# pre-seed raspios's "make a new user" process
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
crypt_pas=$(openssl passwd -6 -in ${rootfs}/etc/ssh/password.txt)
fname=${bootfs}/userconf.txt
printf "%s:%s" ${user} ${crypt_pas} > ${fname}

