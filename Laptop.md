# Laptop planning

Layout/plan for the laptop.

# Hardware

Laptop is System76 Lemur Pro (lemp9).

* Storage: 1 TB + 2 TB drive

# Partitioning layout

```
nvme0n1             931.5G  
├─nvme0n1p1         512M            vfat    /efi
│ └─/EFI/Arch                       bind   ⮩/boot
└─nvme0n1p2         931G
  └─cryptos                         LUKS
    └─Laptop-OS     931G            btrfs   /mnt/os-drive
      │ * These are Archlinux related subvolumes
      ├─@arch-root                          /
      │ ├─var/cache/pacman/pkg      no CoW  <nested subvolume>
      │ ├─var/lib/libvirt           no CoW  <nested subvolume>
      │ ├─var/lib/machines          no CoW  <nested subvolume>
      │ ├─var/lib/mysql             no CoW  <nested subvolume>
      │ ├─var/lib/portables         no CoW  <nested subvolume>
      │ ├─var/tmp                   no CoW  <nested subvolume>
      │ └─srv                               <nested subvolume>
      ├─@arch-log                           /var/log
      ├─@arch-snap                  no CoW  /.snapshots
      ├─@arch-swap                  no CoW  /.swap
      │ * These are gentoo subvolumes
      ├─@gentoo-root                        /mnt/gentoo
      ├─@gentoo-snap                no CoW  /mnt/gentoo/.snapshots
      ├─@gentoo-swap                no CoW  /mnt/gentoo/.swap
      ├─@gentoo-dist (no-compress)          /mnt/gentoo/distfiles
      ├─@gentoo-virt                no CoW  /mnt/gentoo/vm
      │ * These are shared subvolumes
      ├─@home                       no CoW  /home
      └─@opt                        no CoW  /opt
nvme1n1             1.8T
├─nvme1n1p1         100M            vfat    Windows ESP
├─nvme1n1p2          16M            vfat    Windows reserved
├─nvme0n1p3         100G            ntfs    /mnt/windows
├─nvme0n1p4         100G            ntfs    (Windows recovery partition)
└─nvme0n1p5         1.6T
  └─cryptdata                       LUKS
    └─Laptop-Data   1.6T            ext4    /home/data
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
* Calculated the needed amount of blocks to reserve for 2GiB `echo $((2 * 1024**3 / 4096))`
* Reserved this many blocks `sudo tune2fs -r 524288 /dev/mapper/cryptdata`
* Made mount point for this partition to store user data here
