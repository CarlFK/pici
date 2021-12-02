#!/bin/bash -ex

apt install -y ufw

ufw enable
ufw default deny incoming
ufw default allow outgoing

# ssh in from outside
ufw allow in on eth-uplink to any port 22129 proto tcp

# everything from the inside
ufw allow in on eth-local to any

# restrict nfs to eth-local
echo RPCNFSDOPTS="-H 10.21.0.1" >> /etc/default/nfs-kernel-server

# pxe setup installed nginx - we don't use it
apt remove --assume-yes nginx-common
