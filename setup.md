## Summary:
 0. make box with dnsmasq
 1. push setup2.sh and conf files to it
 2. run setup2.sh
 3. boot pi, run setup3.sh
 4. put server into production mode
 5. boot lots of pi'

## Step 0.0
# build a dnsmasq server.

Here is how I do it:
https://github.com/CarlFK/veyepar/wiki/System-Stack#what-to-do-first
don't do this:
The installer will prompt you for a few values:
```
hostname: voctotest
```
We don't want a video mixer, so set hostname to `bare`.  This gives you a simple debian box.

Once the install is done, change the hostname to negk (negk is a tribute to the PS1 member that gave me the laptop I am using to develop this.)

## Step 0.1
Prep for Ansible - put your public key into the user and root:
```
ssh-copy-id juser@negk
ssh juser@negk
sudo apt install ssh-import-id
sudo ssh-import-id lp:carlfk # give root your own public key
sudo apt-get update --allow-releaseinfo-change; sudo apt upgrade
```

## Step 0.2
Use your inventory parameters and the DC Video Team playbook to setup a pxe server:

Clone this repo and the dc-video team ansible next to each other:
```
git clone https://github.com/CarlFK/pici
git clone https://salsa.debian.org/debconf-video-team/ansible dc_a
```
 - put your machine's hostname (negk) in ansible/inventory/hosts under [pxe] and [users]
 - put your machine's 2 MACs into ansible/inventory/host_vars/negk.yml
 - your admin user in ansible/inventory/group_vars/all/all.yml
 - maybe put your box's IP to ansible/inventory/hosts

```
ansible-playbook dc_a/site.yml --inventory-file pici/ansible/inventory/hosts --user root
Work In Progress: ansilbe the whole thing
ansible-playbook ansible/site.yml --inventory-file ansible/inventory/hosts --user root --limit negk
```
Now you should have a dhcp/dns/tftp server on the local nic.

## Step 1
push files to server:
tip: save time later with a symlink to 2022-xx-yy-raspios-bullseye-armhf-lite.img.xz
```
cd pici
rsync -axvP --copy-links setup2.sh files root@negk:
```
## Step 2
Get and tweek files and configs to netboot
```
ssh root@negk
./setup2.sh
```
## Step 3
Boot netboot a Pi, you should see activity on server:
```
tail -F /var/log/daemon.log
```
### Step 3.1
Put the system into maintance mode (pi can update the server)
update packages, install overlayroot (mount / on tmpfs over nfs)
(this could be done with qemu on the server...)
```
files/scripts/maintenance.sh
```
### Step 3.2
reboot the pi,
Log into pi as root
```
./setup3.sh
```
## Step 4
Put the system into production mode (nfs is ro, enable overlayroot on pi)
```
files/scripts/normal.sh
```
## Step 5
Turn on all the pi's

