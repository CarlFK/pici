#!/usr/bin/env bash

# 
set -e
# want to see what is happening
set -x

release="${release:-trixie}"
target="${target:-${1}}"
target="${target:-/mnt/target}"
rootfs_name="${rootfs_name:-root}"
firmwarefs_name="${firmwarefs_name:-boot}"
nfs_base="${nfs_base:-/srv/nfs/rpi/${release}}"
rootfs="${rootfs:-${nfs_base}/${rootfs_name}}"
firmwarefs="${firmwarefs:-${nfs_base}/${firmwarefs_name}}"

error_cleanup()
{
  umount --recursive --lazy "${target}"
}

trap error_cleanup ERR

log_error()
{
  printf "Error: %s\n" "${*}"
  error_cleanup
  exit 1
} >&2

if ! [[ -d "${rootfs}" ]]; then
  log_error "No such root-fs ${rootfs}"
fi
if ! [[ -d "${firmwarefs}" ]]; then
  log_error "No such firmware-fs ${firmwarefs}"
fi


if ! mount | grep -q "${target} "; then
  mount --bind "${rootfs}" "${target}"
fi

if ! [[ -d "${target}/boot/firmware" ]]; then
  log_error "No mountpoint for firmware-fs at ${target}/boot/firmware"
fi

if ! mount | grep -q "${target}/boot/firmware "; then
  mount --bind "${firmwarefs}" "${target}/boot/firmware"
fi

# do not mount the entire devtmpfs just the nodes we need
mount -t tmpfs devs "${target}/dev"
mount -t sysfs sysfs "${target}/sys"
mount -t proc procfs "${target}/proc"

# create only the block device nodes for the device in use
mknod "${target}/dev/null" c 1 3
mknod "${target}/dev/zero" c 1 5
mknod "${target}/dev/full" c 1 7
mknod "${target}/dev/random" c 1 8
mknod "${target}/dev/urandom" c 1 9

mount -t tmpfs -o nodev,nosuid tmpfs "${target}/run"
mkdir --parents "${target}/run/systemd/resolve/"
touch "${target}/run/systemd/resolve/stub-resolv.conf"
mount --bind /etc/resolv.conf "${target}/etc/resolv.conf"

mount -t tmpfs -o rw,nosuid,nodev,relatime,mode=777 tmpfs "${target}/tmp"
