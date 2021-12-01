#!/bin/bash -ex

apt install ufw

cp ufw /etc/default
cp sysctl.conf /etc/ufw
cp before.rules /etc/ufw

ufw disable
ufw enable

cp sshd_config /etc/ssh/
