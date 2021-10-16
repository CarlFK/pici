# https://github.com/CarlFK/pici/blob/main/setup.txt

Step 0.0: https://github.com/CarlFK/veyepar/wiki/System-Stack#what-to-do-first
The installer will prompt you for a few values:
    hostname: voctotest
We don't want a video mixer, so set hostname to "bare".

Step 0.1: prep for ansible - put your public key into the user and root:

ssh-copy-id juser@negk
ssh juser@negk
sudo apt install ssh-import-id unzip kpartx nfs-kernel-server
sudo ssh-import-id lp:carlfk
exit

Step 0.9: use DC Video Team playbook to setup a pxe server:
git clone https://salsa.debian.org/debconf-video-team/ansible ansible/dc

ansible-playbook ansible/dc/site.yml --inventory-file ansible/inventory/hosts --user root \
 --extra-vars="{ 'ansible_python_interpreter': '/usr/bin/python3'}"

Or setup Dnsmasq on a Debian box however you want.

Step 1: get fies needed:

scp setup2.sh files/* juser@negk:

ssh juser@negk

# local caching proxy is kinda nice:
export http_proxy=http://pc8:8000

wget http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-05-28/2020-05-27-raspios-buster-lite-armhf.zip

unzip 2020-05-27-raspios-buster-lite-armhf.zip

Step 2: shuffle the files around
sudo ./setup2.sh

sudo tail -F /var/log/daemon.log
