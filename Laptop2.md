# Laptop planning

Layout/plan for the laptop.

# Hardware

Laptop is System76 Lemur Pro (lemp9).

* Storage: 1 TB + 2 TB drive

# Partitioning layout

```
#-Drive-#           #-Size-#        #-FS-#  #-Mount-#
nvme0n1             931.5G  
├─nvme0n1p1         512M            vfat    /efi    -> /mnt/gentoo/boot
│ │ * The main EFI system partition
│ └─/EFI/Arch                       bind            -> /boot
└─nvme0n1p2         931G
  └─cryptos                         LUKS
    └─Laptop-OS     931G            btrfs   /mnt/filesystem-btrfs
      │ * These are Archlinux related subvolumes
      ├─@arch-root                          /
      │ │ * Nested subvolumes here
      │ ├─var/cache/pacman/pkg      no CoW  <nested subvolume>
      │ ├─var/lib/libvirt           no CoW  <nested subvolume>
      │ ├─var/lib/machines          no CoW  <nested subvolume>
      │ ├─var/lib/mysql                     <nested subvolume>
      │ ├─var/lib/portables                 <nested subvolume>
      │ ├─var/tmp                   no CoW  <nested subvolume>
      │ └─srv                               <nested subvolume>
      ├─@arch-log                           /var/log
      ├─@arch-snap                          /.snapshots
      ├─@arch-swap                  no CoW  /swap
      │ * These are gentoo subvolumes
      ├─@gentoo-root                        /mnt/gentoo
      ├─@gentoo-snap                        /mnt/gentoo/.snapshots
      ├─@gentoo-swap                no CoW  /mnt/gentoo/swap
      ├─@gentoo-dist                no CoW  /mnt/gentoo/distfiles
      ├─@gentoo-virt                no CoW  /mnt/gentoo/vm
      │ * These are Nix-OS subvolumes
      ├─@nixos-LATER
      │ * These are shared subvolumes
      ├─@roothome                           /root   -> /mnt/gentoo/root
      ├─@home                               /home   -> /mnt/gentoo/home
      └─@opt                                /opt    -> /mnt/gentoo/opt
nvme1n1             1.8T
├─nvme1n1p1         100M            vfat    /efi/EFI/Windows
│ * We let windows use this drive; and don't mess with the main system drive.
├─nvme1n1p2          16M            vfat
│ * This is windows reserved; no idea what it does.
├─nvme0n1p3         100G            ntfs    /mnt/windows
│ * Main Windows drive; we mount this so that we can transfer files.
├─nvme0n1p4                         ntfs
│ * Windows recovery partition.
└─nvme0n1p5         1.6T
  │ * Extra space to use.
  └─Laptop-Data                     LUKS
    └─Laptop-Data   1.6T            ext4    /home/data -> /mnt/gentoo/home/data
sda                 3.6T
├─sda1              100M            vfat    /efi/EFI/Windows
│ * We let windows use this drive; and don't mess with the main system drive.
├─sda2               16M            vfat
│ * This is windows reserved; no idea what it does.
├─sda3              100G            ntfs    /mnt/windows
│ * Main Windows drive; we mount this so that we can transfer files.
├─sda4                              ntfs
│ * Windows recovery partition.
└─sda5              3.4T
  │ * Extra space to use.
  └─Laptop-Data                     LUKS
    └─Laptop-Data   3.4T            ext4    /home/data -> /mnt/gentoo/home/data
```

# Installation Steps

## Windows steps

These are what I followed

* Install Windows to the external SSD.
* Installed Firefox and Zotero there, and logged in.
* Disable fast startup on Windows.
* Set time to use UTC on hardware with windows.
* Disable time correction in windows

## Linux steps

* Opened luks container in data ssd.
* Generated random key with `sudo dd bs=512 count=4 if=/dev/random of=/root/laptop-data.keyfile iflag=fullblock`
* Added LUKS key using `sudo cryptsetup luksAddKey /dev/nvme1n1p5 /root/laptop-data.keyfile`
* Made Ext4 filetype without reserved blocks `sudo mkfs.ext4 -m 0 /dev/mapper/cryptdata`
* Calculated the needed amount of blocks to reserve for 4GiB `echo $((4 * 1024**3 / 4096))`
* Reserved this many blocks `sudo tune2fs -r 1048576 /dev/mapper/cryptdata`
* Made mount point for this partition to store user data here:
* Edited fstab and the pkgbuild to prep for migration
* Rebooted to make sure fstab changes worked.
* Copied Media folder from home to data directory using rsync with archive, verbose and -h.
* Migrated videos and pictures folder to Media
* Copied over `/root`, `/etc`, `/home/sbp` as backup to the new folder
* Made archiso
* Booted into the archiso
* Opened crypt containers as cryptos and cryptdata
* Shut down old LVM using `vgchange -a n Laptop`
* Run `mkfs.btrfs -f -L 'Laptop-Linux' /dev/mapper/cryptos`
* Mount the partition using `mount -o compress=zstd /dev/mapper/cryptos /mnt`
* Created subvolumes of the <@name> varieties.
* Unmounted and remounted `@arch-root`
* Created directories; and gave them immutable attribute `chatter +i <mountpoint>` before mounting.
* Mounted the `@arch-root`, `@arch-snap`, `@arch-swap` and `@arch-log` in the file hierarchy.
* Disabled CoW on swap subvolume; `chattr +C /mnt/swap` (do after mounting)
* Created swap file of 45 GiB; `dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=46080 status=progress`
* Made proper permissions by `chmod 0600 /mnt/swap/swapfile`
* Made swapfile by `mkswap -U clear /swapfile`
* Created directories and subvolumes as explained in the above layout
* Pacstrapped base package to `/mnt`
* Edited in my repo in `/mnt/etc/pacman.conf`
* Chrooted in and set root user password
* Installed one by one; `sbp-archlinux`, `sbp-editor`, `sbp-media`, `sbp-applications`, `sbp-gui-bspwm`, `sbp-gui-river`, `sbp-cmp-laptop` and `sbp-gaming`.
* Got the /etc files; `rsync --archive --verbose /home/data/etc/ /etc/`
* Got the home files; `rsync --archive /home/data/sbp/ /sbp/`
* Got the root files; `rsync --archive --verbose /home/data/root/ /root/`
* Edited the files in the `sbp-laptop-cmp` so that correct boot parameters are used.
* Moved key file to `/etc/cryptsetup-keys.d/Laptop-Data.key`
* Cleaned the hard drive of the backup directories, and checked home symlinks.
* Everything working
