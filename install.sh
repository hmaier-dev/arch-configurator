#!/bin/bash

echo -e "Welcome the the Arch Install."
echo -e "Downloading packages..."

# confirm system clocks accuarcy
timedatectl set-ntp true
# Partition the drives

if [ -d /sys/firmware/efi/efivars ];then
    echo -e  "EFI system"
else
    echo -e  "BIOS System"    
fi


#PGS=[
#"synchting"
#"brave-browser"
#"bspwm"
#"gvim"
#"htop"
#"locate"
#"pdfarranger"
#"python"
#"rsync"
#"sudo"
#"sxhkd"
#"thunar"
#"tumbler"
#"vim"
#"cronie"
#"xfce4-terminal"
#]
#
#for PKG in '${PKGS[@]}';do
#    echo -e $PKG
#done  
