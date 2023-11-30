#!/bin/bash
# generate a random password for pi user
# usage: pipw.sh username [password]

user=${1:-pi}

if [ "$#" -eq 2 ]; then
    pass=$2
else
    # generate a password
    pass=$(pwgen)
fi

# save it in the clear so everyone can see it when they want to root the box
printf "%s\n" ${pass} > etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s\n" ${pass} >>  etc/issue

# pre-seed raspios's "make a new user" process
crypt_pas=$(openssl passwd -6 -in etc/ssh/password.txt)
# this works for fixit.sh, needs to be fixed for ansible.
# fname=boot/firmware/userconf.txt
fname=boot/userconf.txt
printf "%s:%s" ${user} ${crypt_pas} > ${fname}

# this sets the password of an existing user
# from back when raspios came with a user
# crypt_pass=$(mkpasswd ${pass})
# usermod --root $PWD/root/ --password ${crypt_pass} ${user}

