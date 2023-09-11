#!/bin/bash
echo -e "------------------------------------------------------------"
echo -e "Welcome to the pre-configuration of the"
echo -e "Arch-Configurator!"
echo -e "This script shall be run before first booting up the system."
echo -e "Your root-partition must be labeled 'root'."
echo -e "BEWARE: THIS SCRIPT IS NOT TESTED!"
echo -e "------------------------------------------------------------\n"

## If you have problems with dual-booting arch and windows
## check out the following link:
## https://github.com/spxak1/weywot/blob/main/Pop_OS_Dual_Boot.md

p () { 
	echo -e "Installing package: $1"
	pacman --noconfirm --needed -S $1 >/dev/null 2>&1
}

configure-boot () {

  mkdir -p /boot/loader/entries
  cd /boot/loader/entries
  touch arch.conf

  read -e -p "Does your system own a Intel- or AMD-CPU? [i/a/q]" PROCEED 
  PROCCED=${PROCEED:-n}
  [ $PROCCED == "q" ] && exit
  if [ $PROCCED == "i" ];then
    p "intel-ucode"
    img="intel-ucode.img"
  fi
  if [ $PROCCED == "a" ];then
    p "amd-ucode"
    img="amd-ucode.img"
  fi

  read -e -p "Is your root-partition labeled as: 'ROOT'? [y/n/q]" PROCEED 
  PROCCED=${PROCEED:-n}
  [ $PROCCED == "q" ] && exit
  if [ $PROCCED == "n" ]; then
    p "e2label"
    echo -e "Label it with e2label!"
    exit
  fi
  
  echo -e "Writing arch.conf..."

  echo "
    title   Arch Linux
    linux   /vmlinuz-linux
    initrd  /$img
    initrd  /initramfs-linux.img
    options root="LABEL=ROOT" rw
    " >> arch.conf

  echo -e "Installing systemd-boot"...
  bootctl install

}

read -e -p "Do you want to use systemd-boot? [y/n/q]" PROCEED 
PROCCED=${PROCEED:-n}
if [ $PROCCED == "y" ]; then


