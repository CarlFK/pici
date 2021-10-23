## Summary:
 0. make box with dnsmasq
 1. put setup2.sh and conf files on it
 2. run setup2.sh
 3. boot pi


## Step 0.0
https://github.com/CarlFK/veyepar/wiki/System-Stack#what-to-do-first
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
```

## Step 0.2
Use your inventory parameters and the DC Video Team playbook to setup a pxe server:

Clone this repo and the dc-video team ansible next to each other:
```
git clone https://github.com/CarlFK/pici
git clone https://salsa.debian.org/debconf-video-team/ansible dc_a
```
 - put your machine's 2 MACs into ansible/inventory/host_vars/negk.yml
 - your admin user in ansible/inventory/group_vars/all/all.yml
 - maybe put your box's IP to ansible/inventory/hosts

```
ansible-playbook dc_a/site.yml --inventory-file pici/ansible/inventory/hosts --user root
```
Now you should have a dhcp/dns/tftp server on the local nic.

## Step 1
get fies needed:
```
cd pici
rsync -axv setup2.sh files juser@negk:
```
## Step 2
shuffle the files around
```
ssh juser@negk
# local caching proxy is kinda nice:
export http_proxy=http://pc8:8000
sudo ./setup2.sh
```

## Step 3
Boot Pi!  You should see activity:
```
sudo tail -F /var/log/daemon.log
```

# 30 min of updates:
sudo apt-get update --allow-releaseinfo-change
```
