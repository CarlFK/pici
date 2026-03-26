#!/usr/bin/env bash

# All you need is to mount a fake /dev/ with null/zero/full/random/urandom in, include procfs and sysfs, ensure your boot-fs is mounted at /boot/firmware/ inside it, add a link for resolv.conf so it has network DNS resolver, then chroot /mnt/target and you should be able to install packages, run mkinitramfs (to create a new initramfs8), and move it into place (after backing-up the original!). Do exit to leave the chroot, than umount --lazy --recursive /mnt/target to unload everything you've set up.

#
set -e
# want to see what is happening
set -x

target="${target:-${1}}"
device="${device:-${2}}"
target="${target:-/mnt/target}"
device="${device:-/dev/sdg}"
pt_rootfs="${pt_rootfs:-3}"
pt_efisp="${pt_efisp:-1}"

error_cleanup()
{
  umount --recursive --lazy "${target}"
}

trap error_cleanup ERR

log_error()
{
  printf "Error: %s\n" "${*}"
  exit 1
} >&2

if ! [[ -e "${device}" ]]; then
  log_error "No such device ${device}"
elif ! [[ -e "${device}${pt_rootfs}" ]]; then
  log_error "No root-fs partition ${device}${pt_rootfs}"
elif ! [[ -e "${device}${pt_efisp}" ]]; then
  log_error "No EFI-SP partition ${device}${pt_efisp}"
fi

if ! mount | grep -q "${target} "; then
  mount "${device}${pt_rootfs}" "${target}"
fi
if ! mount | grep -q "${target}/boot/efi "; then
  mount "${device}${pt_efisp}" "${target}/boot/efi"
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

mkdir --parents "${target}/dev/disk/by-uuid"
for dev in "${device}"*; do
  read -r major minor <<< "$( stat --format='%Hr %Lr' "${dev}" )"
  mknod "${target}${dev}" b "${major}" "${minor}"
  uuid="$( blkid -s UUID -o value "${dev}" )"
  if [[ -n "${uuid}" ]]; then
    ln --symbolic --relative "${target}${dev}" "${target}/dev/disk/by-uuid/${uuid}"
  fi
done

mount -t tmpfs -o nodev,nosuid tmpfs "${target}/run"
mkdir --parents "${target}/run/systemd/resolve/"
touch "${target}/run/systemd/resolve/stub-resolv.conf"
mount --bind /run/systemd/resolve/stub-resolv.conf "${target}/run/systemd/resolve/stub-resolv.conf"
