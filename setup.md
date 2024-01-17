## Summary:
 0. build bare debian box ready for ansible
 1. ansible part 1 - everything needed to netboot a pi, and the public facing server bits
 2. put server into update mode (pi has rw access to its files)
 3. boot pi, mabye ansible, maybe setup3.sh?
 4. put server into production mode
 5. boot lots of pi'

## Step 0
# build a dnsmasq server.

Here is how I do it:
https://github.com/CarlFK/veyepar/wiki/System-Stack#what-to-do-first

When the setup process asks for `hostname: voctotest` use `bare`.
(we don't want a video mixer, we want a simple debian box.)

## Step 1
Once the base install is done: setup ssh keys, ip address, hostname.

ssh in:
```
sudo apt install ssh-import-id
sudo ssh-import-id carlfk # give root your own public key
sudo apt-get update --allow-releaseinfo-change; sudo apt upgrade
```
Use your inventory parameters and the DC Video Team playbook to setup a pxe server:

Clone this repo and the dc-video team ansible next to each other:
```
git clone https://github.com/CarlFK/pici
git clone https://salsa.debian.org/debconf-video-team/ansible dc_a
```
 - put your machine's hostname in ansible/inventory/hosts under [pxe] and [users]
 - put your machine's 2 MACs into ansible/inventory/host_vars/negk.yml
 - your admin user in ansible/inventory/group_vars/all/all.yml
 - maybe put your box's IP to ansible/inventory/hosts

```
ansible-playbook dc_a/site.yml --inventory-file pici/ansible/inventory/hosts --user root
ansible-playbook ansible/site.yml --inventory-file ansible/inventory/hosts --user root --limit negk
```
Now you should have a dhcp/dns/tftp server on the local nic.

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

