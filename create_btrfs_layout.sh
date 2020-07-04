#!/bin/bash
# Create my filesystem layout on a directory using btrfs stuff

# Rename input variable
target_dir="${1}"

if [ -z "${target_dir}" ] ; then
  echo 'Need directory argument.'
  exit 1
elif [ ! -d "${target_dir}" ] ; then
  echo 'Needs to be a directory.'
  exit 2
elif ! mountpoint "${target_dir}" >/dev/null 2>&1 ; then
  echo 'Needs to be a mount point.'
  exit 3
elif [ "$(ls -A "${target_dir}")" ] ; then
  echo 'Directory is not empty.'
  exit 4
fi

# Make the main subvolumes
btrfs subvolume create "${target_dir}/@root"
btrfs subvolume create "${target_dir}/@snapshots"
btrfs subvolume create "${target_dir}/@varlog"
btrfs subvolume create "${target_dir}/@swap"

# Create folders that will be mount points
mkdir "${target_dir}/@root/.snapshots"
mkdir "${target_dir}/@root/boot"
mkdir "${target_dir}/@root/efi"
mkdir "${target_dir}/@root/home"
mkdir "${target_dir}/@root/opt"
mkdir "${target_dir}/@root/swap"
mkdir --parents "${target_dir}/@root/var/log"
# Create the nested subvolumes in the root subvolume
btrfs subvolume create "${target_dir}/@root/srv"
btrfs subvolume create "${target_dir}/@root/var/abs"
mkdir --parents "${target_dir}/@root/var/cache/pacman"
btrfs subvolume create "${target_dir}/@root/var/cache/pacman/pkg"
mkdir --parents "${target_dir}/@root/var/lib"
btrfs subvolume create "${target_dir}/@root/var/lib/machines"
btrfs subvolume create "${target_dir}/@root/var/lib/libvirt"
btrfs subvolume create "${target_dir}/@root/var/lib/mysql"
btrfs subvolume create "${target_dir}/@root/var/lib/portables"
btrfs subvolume create "${target_dir}/@root/var/tmp"
# Disable CoW
chattr +C "${target_dir}/@swap"
chattr +C "${target_dir}/@root/var/lib/mysql"
chattr +C "${target_dir}/@root/var/lib/libvirt"
# Prepare the swap file with 0 size
truncate -s 0 "${target_dir}/@swap/swapfile"
chattr +C "${target_dir}/@swap/swapfile"
btrfs property set "${target_dir}/@swap/swapfile" compression none
# dd if=/dev/zero of="${target_dir}/@swap/swapfile" bs=1M count=10K status=progress
# chmod 600 "${target_dir}/@swap/swapfile"
# mkswap "${target_dir}/@swap/swapfile"
