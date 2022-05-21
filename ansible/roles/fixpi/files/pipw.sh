#!/bin/bash
# generate a random password for pi user

# pass in the username

user=$1

# generate a password
pass=$(pwgen)

# save it in the clear so everyone can see it when they want to root the box
printf "%s\n" ${pass} > root/etc/ssh/password.txt

# append it to the text that is displayed on the console
printf "%s\n" ${pass} >>  root/etc/issue

# pre-seed raspios's make a new users
# echo 'mypassword' | openssl passwd -6 -stdin
crypt_pas=$(openssl passwd -6 env:pass)
printf "%s:%s" ${user} ${crypt_pas} > boot/userconf.txt

# this sets the password of an existing user
# crypt_pass=$(mkpasswd ${pass})
# usermod --root $PWD/root/ --password ${crypt_pass} ${user}

