#!/bin/bash -ex

# uppi1.sh
# run on the pi

# may install a new kernel.
# kernel version is needed by KERN=$(uname -r)
# so reboot an run uppi2.sh

apt update --allow-releaseinfo-change
apt upgrade --assume-yes
apt autoremove --assume-yes

# dpkg-divert: error: rename involves overwriting '/usr/share/vim/vim82/doc/help.txt.vim-tiny' with different file '/usr/share/vim/vim82/doc/help.txt', not allowed
# so remove it
apt remove vim-tiny --assume-yes

# apt install --assume-yes eatmydata

apt install --assume-yes ssh-import-id vim tmux \
    git etckeeper sshfs tio rsync openocd fxload \
    jq software-properties-common

# E: Package 'sftp' has no installation candidate
# E: Unable to locate package flterm

# flcli=makestuff/apps/flcli/lin.x64/rel/flcli
# fx2loader=makestuff/apps/fx2loader/lin.x64/rel/fx2loader
# https://github.com/matrix-io/xc3sprog

apt install --assume-yes \
    gstreamer1.0-plugins-base-apps

apt autoremove --assume-yes

cat <<EOT
rebooting....
ssh in again and run uppi2.sh
EOT
reboot
