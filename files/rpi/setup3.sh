#!/bin/bash -ex

# setup3.sh
# run on the pi

sudo apt-get update --allow-releaseinfo-change
apt upgrade --assume-yes
apt install ssh-import-id
apt install ./overlayroot_0.47ubuntu1_all.deb
