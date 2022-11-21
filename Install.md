# Arch Linux Installation Guide

This is my Arch installation guide, specialized to pull from my personal repo.

# Installation

Generic instructions for installation are noted here.

## Booting to live-usb
Boot from the usb from there.
(May want to run `loadkeys dvorak`)

## Clean drives (Optional)

To clean drives, open an encrypted container and write zeros on top of it.
```
cryptsetup open --type plain /dev/xxx container --key-file /dev/random
dd if=/dev/zero of=/dev/mapper/container bs=1M status=progress
cryptsetup close container
```

## Partition table

Usually, will want to do GPT, with `parted /dev/DRIVE mklabel gpt`.

### EFI System Partition

Run the following;
```
gdisk /dev/xxx
n
<Return>/1
<Return>
+550M
ef00 (for ESP)
```

### LUKS Partition

Run the following, without quitting gdisk.
```
gdisk /dev/xxx
n
<Return>/<Partition number>/2
<Return>
<Return>/Disk size
8309 (for LUKS)
```

## Encryption

I use LUKS to encrypt my logical volumes.

### Decrypt LUKS container

The command to **open** a LUKS container is as follows;
```
cryptsetup luksOpen [--key-file /path/to.keyfile] <device> <mapper-name>
```

### Random Key generation
Random keys can be generated using
```
dd bs=512 count=4 if=/dev/random of=<OUTPUT_FILE> iflag=fullblock
```

### Creating new container

I use the following to create a LUKS partition
```
cryptsetup \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha384 \
    --iter-time 2500
    --use-random \
    --key-slot X <THIS IS OPTIONAL> \
    luksformat /dev/xxx2
```

### Adding keys to existing container

To add keys from a keyfile (such as the one you randomly generated);
```
cryptsetup [--key-slot X] luksAddKey <PART> [/path/to.keyfile]
```

### Backup container header

To create an image of the header as a backup, run;
```
cryptsetup luksHeaderBackup <PART> --header-backup-file <FILE>.img
```

## Logical Volumes

LVM allows to be flexible with the partitioning layout.
Flexibility also allows encrypting many partitions with one container.

### Create volume groups

```
# Device is usually from unlocked LUKS; which is /dev/mapper/<name>
pvcreate <device>
vgcreate <group-name> <device>
```

### Creating Logical Volumes

After LVM is created, create logical volumes either by hard coding the size;
```
lvcreate --size <size;10G> <group-name> --name <volume-name>
```
or by interpolation
```
lvcreate --extent <size;100%FREE> <group-name> --name <volume-name>
```

## File-systems

### FAT32

The ESP should be fat32
```
mkfs.fat -F 32 -n <name> <partition>
```

### BTRFS

Formatting partition as btrfs
```
mkfs.btrfs --label <part-label> <device>
```

#### Swap-file using btrfs

On kernels greater then 5.0; btrfs and swap files can be used.
The swap file needs to be on a non-snapshotted volume;
hence will need it's own subvolume.
The swapfile needs to be generated as a 0 length file;
```
truncate -s 0 /swapfile/swap
chattr +C /swapfile/swap
btrfs property set /swapfile/swap compression none
fallocate -l <SWAPSIZE> /swapfile/swap
chmod 600 /swapfile/swap
mkswap /swapfile/swap
```

To resume from this swap file; the file extent needs to be calculated.
```
cd /tmp
wget https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
gcc -O2 -o btrfs_map_physical btrfs_map_physical.c
sudo ./btrfs_map_physical <swap-file-on-btrfs>
```
Need to divide the `PHYSICAL OFFSET` (last column)
of the first line (`FILE OFFSET` is 0)
with pagesize, which is given by `getconf PAGESIZE`.
That value needs to be used in the kernel parameter; `resume_offset=<VALUE>`.

### XFS

Use the following command to format a volume as XFS.
Mount will detect the best parameters for XFS.

```
mkfs.xfs -L <partition-label> <volume>
```

## System layout

I use btrfs on the system partition.
The layout I like to use can be seen in my script, but displayed here;
```
/mnt
├── @root
│   ├── (.snapshots): bind point for subvolume @snapshots
│   ├── (boot)      : bind mount for ESP:/EFI/<OS-name>
│   ├── (efi)       : mount point for ESP
│   ├── (home)      : mount point for home partition
│   ├── (opt)       : mount point for separate opt partition; if used
│   ├── srv
│   ├── (swap)      : mount point for subvolume @swap
│   └── var
│       ├── abs
│       ├── cache
│       │   └── pacman
│       │       └── pkg
│       ├── lib
│       │   ├──*libvirt
│       │   ├── machines
│       │   ├──*mysql
│       │   └── portables
│       ├── (log)   : mount point for subvolume @varlog
│       └── tmp
├── @snapshots
├──*@swap
│   └── swapfile
└── @varlog
* Copy on write disabled (with chattr +C <dir>)
```

* Parenthesis indicates not a subvolume; but a directory (for mount points).
* Asterisks indicates subvolumes for which CoW should be turned off.

## Installation

The installation steps are custom to my personal repo.
Most convenient way to install is to mount hard drive to a computer.
If not; adding the repos to live environment should be sufficient.
The command to install is `pacstrap <mnt-point> things`

### Personal repo

To add my own repo to the installation usb, add the lines to `pacman.conf`;

```
cat >>/etc/pacman.conf <<EOF
[sbp]
SigLevel = Optional TrustAll
Server = https://s3.amazonaws.com/sbp-arch/repo
EOF
```

### Mirrorlist on live-usb

To refresh sources, do a partial update, then update repo list

```
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
```

## System configuration

Couple more steps needs to be taken to fully customize the system.

### SSH keys

To restore keys, use the USB.
```
gpg --pinentry-mode loopback --import <secret.subkey>
cp -r <SSHKEYS> ~/.ssh
chmod 700 ~/.local/ssh
chmod 600 ~/.local/ssh/*
```

### Etckeeper

Clone the repo to temporary location, and overwrite the /etc directory.

```
git clone <REPO> /tmp/etc
cp -r /tmp/etc/. /etc/
```

### rEFInd

On fresh installation; rEFInd will not be installed.
Need to run refind-install script to install it to the EFI partition.
If installing from another computer; `refind-install` from chroot works.
However; the EFI entry will be on the current hardware.
Remove it; and add the entry later on the native hardware.

To register rEFInd in BIOS; use the following command;
```
# This example is for ESP on /dev/sda1. Adjust accordingly
efibootmgr --create --disk /dev/sda --part 1 --loader /EFI/refind/refind_x64.efi --label "rEFInd Boot Manager" --verbose
```
