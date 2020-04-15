# Arch Linux Installation Guide

This is my Arch installation guide, specialized to pull from my personal repo.

# Installation

Generic instructions for installation are noted here.

## Create ISO (Optional)

This is an alternative; to customize an iso image.
<Revisit this once I actually do this again>

## Create live usb

Install the live-iso either from the torrent, or the mirrors.
Checking the gpg-keys can be made with the following commands;

```
gpg --keyserver-options auto-key-retrieve --verify archlinux-20XX.YY.ZZ-x86_64.iso.sig
pacman-key -v archlinux-20XX.YY.ZZ-x86_64.iso.sig
```

To write the live USB (the archiso is compatible with all boot modes by default)

```
sudo dd if=Downloads/archlinux-20XX.YY.ZZ-ARCH.iso of=/dev/sdX bs=4M status=progress oflag=sync 
```

## Booting to live-usb
Boot from the usb from there.
May want to run `loadkeys dvorak`

## Clean drives (Optional)

To clean drives, open an encrypted container and write zeros on top of it.
```
cryptsetup open --type plain /dev/xxx container --key-file /dev/random
dd if=/dev/zero of=/dev/mapper/container bs=1M status=progress
cryptsetup close container
```

## Partition table

Usually, will want to do GPT, with `parted /dev/DRIVE mklabel gpt`.

To create ESP, the following works using gdisk.

```
gdisk /dev/xxx
o
n
1
<Return>
+550M
ef00
```

To create LUKS partitions, only the partition type needs to change

```
gdisk /dev/xxx
o
n
<Return>/<Partition number>
<Return>
<Return>/Disk size
8309
```

## LUKS

I use LUKS to encrypt my logical volumes.

### Decrypting container
To decrypt a luks container, run the following;
```
cryptsetup luksOpen [--key-file /path/to.keyfile] <device> <mapper-name>
```

### Random key generation
Random keys can be generated using
```
dd bs=512 count=4 if=/dev/random of=<OUTPUT_FILE> iflag=fullblock
```

### Creating new container
To create LUKS containers, the following command should be enough.
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

### Adding additional keys
To add keys from a keyfile (such as the one you randomly generated);
```
cryptsetup [--key-slot X] luksAddKey <PART> /path/to.keyfile
```
Omit the keyfile argument to just input using self.

### Backup the container header
To create an image of the header as a backup, run
```
cryptsetup luksHeaderBackup <PART> --header-backup-file <FILE>.img
```

## LVM
LVM allows to be flexible with the partitioning layout.
I usually use LVM on LUKS; because it makes it such that all partitions are
encryted using one container.

### Create container
```
pvcreate <device>
vgcreate <group-name> <device>
```

### Create logical Volumes

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

The boot partition should be fat32
```
mkfs.fat -F 32 -n <name> <partition>
```

### Swap

#### Partition
To declare swap space;
```
mkswap -L Swapspace <device>
swapon <device>
```

### BTRFS

Formatting partition as btrfs
```
mkfs.btrfs --label <part-label> <device>
```

#### Swap-file using btrfs
On kernels greater then 5.0; btrfs and swap files can be used.
The swap file needs to be on a non-snapshotted volume; hence will need it's own
subvolume.
The swapfile needs to be generated as a 0 length file.
```
truncate -s 0 /swapfile/swap
chattr +C /swapfile/swap
btrfs property set /swapfile/swap compression none
fallocate -l <SWAPSIZE> /swapfile/swap
chmod 600 /swapfile/swap
mkswap /swapfile/swap
```

### XFS

Use the following command to format a volume as XFS.
Mount will detect the best parameters for XFS.

```
mkfs.xfs -L <partition-label> <volume>
```

## System layout

I use btrfs on the system partition.
The following layout I find to be most beneficial.
These commands assume you are on arch, and the btrfs is on `/dev/Linux/Arch`
```
mount /dev/mapper/Linux-Arch /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@snapshots
umount /mnt

mount -o rw,nodiscard,noatime,nodiratime,compress=lzo,space_cache,subvol=@root /dev/mapper/Linux-Root /mnt
mkdir -p /mnt/{boot/efi,esp,home,.snapshots}
mount -o rw,nodiscard,noatime,nodiratime,compress=lzo,space_cache,subvol=@snapshots /dev/mapper/Linux-Root /mnt/.snapshots
mkdir -p /mnt/var/cache/pacman
mkdir -p /mnt/var/lib
btrfs subvolume create /mnt/swapfile
btrfs subvolume create /mnt/var/abs
btrfs subvolume create /mnt/var/cache/pacman/pkg
btrfs subvolume create /mnt/var/lib/machines
btrfs subvolume create /mnt/var/tmp
btrfs subvolume create /mnt/var/log
btrfs subvolume create /mnt/srv
```

I also usually mount the ESP at /boot/efi

```
mount <partition> /mnt/boot/efi
```

## Installation

The installation steps are custom to my personal repo.

### Repositories

To add my own repo to the installation usb, use;

```
cat >>/etc/pacman.conf <<EOF
[sbp]
SigLevel = Optional TrustAll
Server = https://s3.amazonaws.com/sbp-arch/repo
EOF
```

To refresh sources, do a partial update, then update repo list

```
pacman -Sy
pacman -S reflector
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
pacstrap /mnt <MY-PACKAGES>
```

### Keys
To restore keys, use my special usb.
```
gpg --pinentry-mode loopback --import <secret.subkey>
cp -r <SSHKEYS> ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```
There will be a tar file to do this in the future

### Etc
To restore etckeeper git files, I need to clone to temp then copy over all files;
To do that, the root user needs my machine specific SSH keys from the user.
My packagen should do this automatically, but if not;
put this in the config line of the root user.

```
Host github.com
    User bbaserdem
    IdentitiesOnly yes
    IdentityFile /home/sbp/.ssh/id_ed25519_GITHUB
```

Then clone the repo to temporary location, and overwrite the directory.

```
git clone <REPO> /tmp/etc
cp -r /tmp/etc/. /etc/
```

## Booting
Several steps needs to be taken to ensure successful boot.

### Fstab

The fstab will be screwed up on generation. Still, from archiso, do;
```
genfstab -U /mnt >> /mnt/etc/fstab
```

### rEFInd

The main repo has scripts that will automatically load refind to `/esp/EFI/rEFInd`.
The config needs to be hand-generated.
After generation, use the following command to register refind in bios;
```
efibootmgr --create --disk /dev/sda --part 1 --loader /EFI/refind/refind_x64.efi --label "rEFInd Boot Manager" --verbose
```

### Initramfs

Need to generate a proper initramfs.
