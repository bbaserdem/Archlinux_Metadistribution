# Home Computer

Some results of blkid command

```
$ sudo blkid
/dev/nvme2n1p1: LABEL_FATBOOT="ESP" LABEL="ESP" UUID="585A-EF43" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="EFI System" PARTUUID="b2732cc8-dcb3-46ad-af73-d0f1e7743d92"
/dev/nvme2n1p2: UUID="dfe78f22-c728-429e-a301-45008115c28b" TYPE="crypto_LUKS" PARTLABEL="Linux LUKS" PARTUUID="db256c3e-099b-496d-a135-5483d9a20efb"
/dev/mapper/Home-OS:    LABEL="Work-Linux" UUID="25b3f901-a8d2-4af4-bf67-52b2884d90c4" UUID_SUB="9ee65bfd-539e-44b1-bdf4-748038ef5c7b" BLOCK_SIZE="4096" TYPE="btrfs"
/dev/nvme1n1p5: UUID="bb9bb99d-1eac-451f-8212-375742300eeb" TYPE="crypto_LUKS" PARTLABEL="Linux LUKS" PARTUUID="d976d656-88b9-48ae-8de8-aec17c8a263c"
/dev/mapper/Home-Data:  UUID="218c065b-baeb-426c-b2b5-38f3f598f920" BLOCK_SIZE="4096" TYPE="ext4"
/dev/nvme0n1p5: UUID="db8b2e2c-ad47-473f-8560-e7937002b539" TYPE="crypto_LUKS" PARTLABEL="Work-Extra" PARTUUID="4b9a89a0-c136-4a80-b8c1-0a7577bfe030"
/dev/mapper/Home-Work:  UUID="61243ad2-de50-45f3-bff6-33687643ec75" BLOCK_SIZE="4096" TYPE="ext4"
$ lsblk
NAME          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS                BY-ID
nvme1n1       259:0    0   1.9T  0 disk  
└─nvme1n1p5   259:1    0   1.7T  0 part  
  └─Home-Data 254:1    0   1.7T  0 crypt /mnt/gentoo/home/data
                                         /home/data
nvme2n1       259:2    0 476.9G  0 disk  
├─nvme2n1p1   259:3    0   550M  0 part  /mnt/gentoo/boot
│                                        ...
└─nvme2n1p2   259:4    0 476.4G  0 part  
  └─Home-OS   254:0    0 476.4G  0 crypt /mnt/gentoo/vm
                                         ...
nvme0n1       259:5    0   1.8T  0 disk  
└─nvme0n1p5   259:6    0   1.7T  0 part  
  └─Home-Work 254:2    0   1.7T  0 crypt /mnt/gentoo/home/work
$ ls -la /dev/disk/by-id
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-eui.0000000001000000e4d25cdb38e55001 -> ../../nvme1n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-INTEL_SSDPEKNW020T8_PHNH922200QG2P0C -> ../../nvme1n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-INTEL_SSDPEKNW020T8_PHNH922200QG2P0C_1 -> ../../nvme1n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-eui.0025385591b40636 -> ../../nvme2n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-Samsung_SSD_970_PRO_512GB_S463NF0M531040W -> ../../nvme2n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-Samsung_SSD_970_PRO_512GB_S463NF0M531040W_1 -> ../../nvme2n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-nvme.1c5c-415342344e373138313131303034523545-5348475033312d32303030474d-00000001 -> ../../nvme0n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-SHGP31-2000GM_ASB4N718111004R5E -> ../../nvme0n1
lrwxrwxrwx 1 root root  13 Eki 16 10:48 nvme-SHGP31-2000GM_ASB4N718111004R5E_1 -> ../../nvme0n1
```
