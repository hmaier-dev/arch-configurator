#!/bin/bash

echo -e "------------------------------------------------------------"
echo -e "Welcome to self-configuring Arch!"
echo -e "Run this script after doing pacstrap or"
echo -e "on your first boot."
echo -e "Please only run on fresh installs."
echo -e "------------------------------------------------------------\n"

shopt -s dotglob # for considering dot files (turn on dot files)


# no need to accept a package, don't reinstall already up to date programms, quieten the output
p () { 
	echo -e "Installing package: $1"
	pacman --noconfirm --needed -S $1 >/dev/null 2>&1
}

# Actual script starts!
# Starting point
# Beginning

if [[ $EUID -ne 0  ]]; then
	echo "Run this as root."
	exit 1
fi

read -e -p "Continue with the script? [y/n/q]" PROCEED 
PROCEED=${PROCEED:-n}
[ $PROCEED != "y" ] && exit

read -p "Enter the hostname for this device: " hostname 
# read -p "Enter local username: " username # this variable is needed through the script, even if a user is already created
username=hmaier
# read -p "Enter preferred user id [1001]: " userid
userid=1001
# userid=${userid:-1001}

echo -e "Creating User..."
useradd -m --uid 1001 -G wheel $username

echo -e "Changing password of $username"
passwd $username

echo -e "Copying script for dotfiles management to $username's \$HOME..."
cd /root

cp /root/arch-configurator/sync-dotfiles.sh /home/$username
chown $username /home/$username/sync-dotfiles.sh
chmod +x /home/$username/sync-dotfiles.sh

echo -e "Copying script for installs from the AUR to $username's \$HOME..."
cd /root

cp /root/arch-configurator/aur-install.sh /home/$username
chown $username /home/$username/aur-install.sh
chmod +x /home/$username/aur-install.sh

echo -e "Base Configuration finished."

read -e -p "Continue with packages installation? [y/n/q]" PROCEED 
PROCEED=${PROCEED:-n}
[ $PROCEED != "y" ] && exit

echo -e "Updating the system..."
pacman --noconfirm --needed -Syu $1 >/dev/null 2>&1

echo -e "Downloading packages..."
# take care: this will also read empty lines!
while read -r i; do
	p "$i"
done < /root/arch-configurator/packages-list.txt

echo -e "Finished downloading and installing packages..."

echo -e "Enabling SSH..."
p "openssh"
systemctl enable sshd.service

echo -e "Configuring doas..."
p "opendoas"
echo -e "Creating doas.conf"
touch /etc/doas.conf
echo "permit persist :wheel" >> /etc/doas.conf
echo "permit setenv { XAUTHORITY LANG LC_ALL } :wheel" >> /etc/doas.conf
echo "permit nopass hmaier as root cmd pacman" >> /etc/doas.conf
chown -c root:root /etc/doas.conf
chmod -c 0600 /etc/doas.conf

echo -e "Configuring sudo..."
p "sudo"
# suoders file can just get changed when sudo is installed!
echo -e "Changing the sudoers file..."
sed -i '82i %wheel ALL=(ALL) ALL' /etc/sudoers
sed -i '83d' /etc/sudoers

echo -e "Creating .xinitrc..."
touch /home/$username/.xinitrc
chown $username /home/$username/.xinitrc

echo -e "Removing the beep sound..."
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo -e "Creating work directorys..."
mkdir /home/$username/pics
chown $username /home/$username/pics
mkdir /home/$username/pics/screenshots
chown $username /home/$username/pics/screenshots

echo -e "Creating utility directorys..."
mkdir -p "/home/$username/.log"
chown $username /home/$username/.log

echo -e "Make system-wide configuration..."

#echo -e "Enabling lightdm display manager..."
if [ -d "/etc/lightdm" ]; then
	systemctl enable lightdm --quiet
	sed -i "/#greeter-session=/c\greeter-session=lightdm-gtk-greeter" /etc/lightdm/lightdm.conf
	sed -i "/#display-setup-script=/c\display-setup-script=/usr/bin/setxkbmap de" /etc/lightdm/lightdm.conf
	#sed -i "/#greeter-setup-script=/c\greeter-setup-script=/usr/bin/numlockx on" /etc/lightdm/lightdm.conf
	echo -e "Configuring lightdm..."

	cp /usr/share/pixmaps/archlinux-logo.png /etc/lightdm
	if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ];then
		rm /etc/lightdm/lightdm-gtk-greeter.conf
	fi

	touch /etc/lightdm/lightdm-gtk-greeter.conf
	echo "[greeter]" >> /etc/lightdm/lightdm-gtk-greeter.conf
	echo "background = #5e5c64 " >> /etc/lightdm/lightdm-gtk-greeter.conf
	echo "default-user-image = /etc/lightdm/archlinux-logo.png" >> /etc/lightdm/lightdm-gtk-greeter.conf
fi

echo -e "Set the system clock to local to sync windows and linux..."
timedatectl set-local-rtc 1 --adjust-system-clock

echo -e "Changing the hostname of this device..."
touch /etc/dhcpcd.conf
sed -i "/#hostname/c\hostname=$hostname" /etc/dhcpcd.conf
echo $hostname > /etc/hostname
hostnamectl set-hostname $hostname

echo -e "Setting $username's vim-configuration system-wide..."
mkdir -p /etc/xdg/nvim/sysinit.vim
echo "source /home/$username/.vim/vimrc" >> /etc/xdg/nvim/sysinit.vim

echo -e "Copy xinitrc into \$HOME..."
cp /etc/X11/xinit/xinitrc /home/$username/.xinitrc

echo -e "By default xinit starts bspwm!"
echo "setxkbmap de" >> /home/$username/.xinitrc
echo "exec bspwm" >> /home/$username/.xinitrc

chown $username /home/$username/.xinitrc

echo -e "\n"
echo -e "Now you can log in as $username!"
echo -e "For syncing your dotfiles, run ./sync-dotfiles.sh as $username."
echo -e "Thank you for running the arch-configurator!"

shopt -u dotglob # for don't considering dot files (turn off dot files)
