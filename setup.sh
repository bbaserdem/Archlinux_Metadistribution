#!/bin/dash

# Setup script for archlinux

# Resolvconf
echo '[install(arch)]==> Updating resolvconf'
/usr/bin/resolvconf -u

# User
echo '[install(arch)]==> Creating user sbp'
if [ "$(getent passwd | grep -c '^sbp')" == "0" ]
then
    /bin/useradd --create-home --groups \
        sys,ftp,log,http,games,lock,rfkill,users,video,uucp,lp,input,wheel,kvm \
        --shell /usr/bin/zsh sbp
fi

# Timezone
echo '[install(arch)]==> Setting local time'
/bin/ln -sf /usr/share/zoneinfo/America/New_York "/etc/localtime"
/usr/bin/timedatectl set-ntp true
/usr/bin/hwclock --systohc

# Locale
echo '[install(arch)]==> Generating locale'
/usr/bin/locale-gen

# Services
echo '[install(arch)]==> Enabling services'
/usr/bin/systemctl enable sddm.service
if [ -e /usr/bin/bumblebeed ] ; then
    /usr/bin/systemctl enable bumblebee.service
fi
