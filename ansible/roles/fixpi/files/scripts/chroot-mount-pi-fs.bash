#!/usr/bin/env bash

# chroot-mount-pi-fs.bash [nfs-base] [chroot-root] [cmd]
# nfs-base: the pi's fs (about the sd card files)
# chroot-root: where the root fs will hang out
# cmd: if passed, run it and unmount, else leave the mounts in place.
# example: sudo ./chroot-mount-pi-fs.bash /srv/nfs/rpi/trixie /tmp/pi "apt update"


# handle error
set -e
# want to see what is happening
set -x

nfs_base="${1:-/srv/nfs/rpi/trixie}"
target="${2:-/tmp/pi}"
cmd="${3}"

rootfs_name="${rootfs_name:-root}"
firmwarefs_name="${firmwarefs_name:-boot}"

rootfs="${rootfs:-${nfs_base}/${rootfs_name}}"
firmwarefs="${firmwarefs:-${nfs_base}/${firmwarefs_name}}"

cleanup()
{
  umount --recursive --lazy "${target}"
}

trap cleanup ERR

log_error()
{
  printf "Error: %s\n" "${*}"
  cleanup
  exit 1
} >&2

if ! [[ -d "${rootfs}" ]]; then
  log_error "No such root-fs ${rootfs}"
fi
if ! [[ -d "${firmwarefs}" ]]; then
  log_error "No such firmware-fs ${firmwarefs}"
fi

if ! [[ -d "${target}" ]]; then
  mkdir -p "${target}"
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

if ${cmd}; then
  chroot ${target} ${cmd}
  cleanup
else
  echo chroot ${target}
fi
