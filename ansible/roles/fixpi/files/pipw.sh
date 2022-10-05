#!/bin/bash
# generate a random password for pi user

# pass in the username

user=${1:-pi}

if [ "$#" -eq 2 ]; then
    pass=$2
else
    # generate a password
    pass=$(pwgen)
fi

# save it in the clear so everyone can see it when they want to root the box
printf "%s\n" ${pass} > root/etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s\n" ${pass} >>  root/etc/issue

# pre-seed raspios's make a new users
crypt_pas=$(openssl passwd -6 -in root/etc/ssh/password.txt)
printf "%s:%s" ${user} ${crypt_pas} > boot/userconf.txt

# this sets the password of an existing user
# from back when raspios came with a user
# crypt_pass=$(mkpasswd ${pass})
# usermod --root $PWD/root/ --password ${crypt_pass} ${user}

