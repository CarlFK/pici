#!/bin/bash -ex
# generate a random password for pi user
# usage: pipw.sh username [password]

user=${1:-pi}

if [ "$#" -eq 2 ]; then
    pass=$2
else
    # generate a password
    pass=$(pwgen --ambiguous)
fi

# save it in the clear so everyone can see it when they want to root the box
# note: this file is used by openssl passwd so don't mess it up
# we will find out if the \n messes it up
printf "%s\n" ${pass} > etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s %s\n" ${user} ${pass} >> etc/issue

# pre-seed raspios's "make a new user" process
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
crypt_pas=$(openssl passwd -6 -in etc/ssh/password.txt)
# this works for fixit.sh,
# fname=boot/firmware/userconf.txt
# this is for for ansible:
fname=../boot/userconf.txt
printf "%s:%s" ${user} ${crypt_pas} > ${fname}

# this sets the password of an existing user
# from back when raspios came with a user
# crypt_pass=$(mkpasswd ${pass})
# usermod --root $PWD/root/ --password ${crypt_pass} ${user}

