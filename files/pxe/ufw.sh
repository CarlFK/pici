#!/bin/bash -ex

apt install -y ufw

ufw enable
ufw default deny incoming
ufw default allow outgoing

# ssh in from outside
ufw allow in on eth-uplink to any port 22129 proto tcp

# everything from the inside
ufw allow in on eth-local to any
